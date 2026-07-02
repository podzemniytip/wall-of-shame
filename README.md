# Wall of Shame

A game on Base (chain ID 8453) where anyone can pay to post a short message on-chain, overwriting the previous author — who loses their fee. The accumulating reward pool goes to the last author if their message goes unchallenged for the full delay period.

## Game Rules

- **Post a message**: Pay the fixed `postFee` (e.g. 0.01 ETH) to write a ≤32‑byte message. 7% goes to the dev wallet; the rest is added to the `rewardPool`.
- **Overwrite**: The previous author gets **no refund** — their fee is lost.
- **Claim the reward**: If your message stands unchallenged for `rewardDelay` (e.g. 24 h), you can call `claimReward()` and take the entire `rewardPool`. The message stays; the pool resets to zero.
- **Owner**: Can adjust `postFee` (0.001–0.1 ETH) and `rewardDelay` (1 h – 7 d). `devFeePercent` is immutable.

## Deploy on Remix

### 1. Open Remix

Go to [remix.ethereum.org](https://remix.ethereum.org/).

### 2. Install OpenZeppelin

In the Remix plugin manager, enable **Solidity compiler** (it's on by default). Open the **File Explorers** panel, right-click `contracts` → **Create New File** → name it `WallOfShame.sol`. Paste the contents of `WallOfShame.sol`.

Install OpenZeppelin in Remix:
- Go to the **Solidity compiler** tab.
- Click the **Advanced Configurations** section.
- Enable **"Include OpenZeppelin contracts from GitHub"** (or use Remix's built-in NPM workspace).
- Alternatively, add OpenZeppelin via the **Remix Workspaces** → **GitHub** link: `OpenZeppelin/openzeppelin-contracts` (v5.x).

### 3. Compile

1. Switch to the **Solidity compiler** tab.
2. Select compiler version `0.8.20+`.
3. Click **Compile WallOfShame.sol**.

### 4. Deploy

1. Switch to the **Deploy & run transactions** tab.
2. Select **Injected Provider – MetaMask** as the environment.
3. Make sure MetaMask is on **Base** (chain ID 8453) or **Base Sepolia** (chain ID 84532).
4. Next to **Deploy**, fill in the constructor arguments:

| Argument         | Value (example) | Description                                |
|------------------|-----------------|--------------------------------------------|
| `_postFee`       | `10000000000000000` (0.01 ETH) | Fee in wei to post a message |
| `_devFeePercent` | `700`           | Basis points (7%) sent to dev wallet       |
| `_rewardDelay`   | `86400`         | Seconds before reward is claimable (24 h)  |
| `_feeRecipient`  | `0xYour...`     | Address that receives the 7% dev fee       |

5. Click **transact** and confirm the MetaMask transaction.

6. After deployment, copy the deployed contract address from the Remix terminal.

## Connect the Website

### 1. Update the contract address

Open `index.html` and find this line near the top of the `<script>` block:

```js
const CONTRACT_ADDRESS = "0x0000000000000000000000000000000000000000"; // UPDATE AFTER DEPLOY
```

Replace the zero address with your deployed contract address.

### 2. (Optional) Update the ABI

The ABI is already embedded in `index.html` as a minimal array. If you add or remove functions, paste the full ABI from Remix (compilation details → ABI) into the `ABI` constant.

### 3. Open the site

Simply double-click `index.html` or open it in a browser. MetaMask will prompt you to connect and switch to Base.

## Live Site (jsDelivr CDN — instant, no build queue)

**https://cdn.jsdelivr.net/gh/podzemniytip/wall-of-shame@gh-pages/index.html**

GitHub Pages is experiencing deployment delays. The jsDelivr URL above serves the latest code from the `gh-pages` branch immediately after each push.

## Running Locally

No build tools are needed. The page loads Tailwind CSS and ethers.js from CDN. Just open `index.html` in any modern browser with MetaMask installed.

## Contract Functions

| Function              | Who     | Description                                      |
|-----------------------|---------|--------------------------------------------------|
| `postMessage(string)` | Anyone  | Pay `postFee` to post a ≤32‑char message.        |
| `claimReward()`       | Author  | Claim the reward pool after `rewardDelay`.       |
| `getCurrentMessage()` | Anyone  | View current author, message, timestamp, pool, fee. |
| `setPostFee(uint256)` | Owner   | Change fee (0.001–0.1 ETH).                      |
| `setRewardDelay(uint)`| Owner   | Change delay (1 h – 7 d).                        |
| `emergencyWithdraw()` | Owner   | Withdraw stray funds (not the reward pool).      |

## Events

- `MessagePosted(author, message, timestamp, feePaid)`
- `RewardClaimed(author, amount, timestamp)`

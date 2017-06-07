From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Subject: [Question or BUG] [NUMA]: I feel puzzled at the function
 cpumask_of_node
Date: Wed, 7 Jun 2017 17:23:20 +0800
Message-ID: <5937C608.7010905@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, chenchunxiao <chenchunxiao@huawei.com>, x86l <x86@kernel.org>
List-Id: linux-mm.kvack.org

When I executed numactl -H(print cpumask_of_node for each node), I got different result on X86 and ARM64.
For each numa node, the former only displayed online CPUs, and the latter displayed all possible CPUs.
Actually, all other ARCHs is the same to ARM64.

So, my question is: Which case(online or possible) should function cpumask_of_node be? Or there is no matter about it?

-- 
Thanks!
BestRegards

From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x86_64 Question: Are concurrent IPI requests safe?
Date: Mon, 9 May 2016 18:54:14 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1605091853130.3540@nanos>
References: <201605061958.HHG48967.JVFtSLFQOFOOMH@I-love.SAKURA.ne.jp> <201605092354.AHF82313.FtQFOMVOFJLOSH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201605092354.AHF82313.FtQFOMVOFJLOSH@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Mon, 9 May 2016, Tetsuo Handa wrote:
> 
> It seems to me that APIC_BASE APIC_ICR APIC_ICR_BUSY are all constant
> regardless of calling cpu. Thus, native_apic_mem_read() and
> native_apic_mem_write() are using globally shared constant memory
> address and __xapic_wait_icr_idle() is making decision based on
> globally shared constant memory address. Am I right?

No. The APIC address space is per cpu. It's the same address but it's always
accessing the local APIC of the cpu on which it is called.

Thanks,

	tglx

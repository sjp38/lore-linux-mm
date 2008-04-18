Date: Fri, 18 Apr 2008 00:50:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-mm1: not looking good
Message-Id: <20080418005034.6e4dd9e7.akpm@linux-foundation.org>
In-Reply-To: <20080417160331.b4729f0c.akpm@linux-foundation.org>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Another runtime warning on the t61p:


Brought up 2 CPUs
Total of 2 processors activated (9583.80 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 00000000,00000003
  groups: 00000000,00000001 00000000,00000002
  domain 1: span 00000000,00000003
   groups: 00000000,00000003
CPU1 attaching sched-domain:
 domain 0: span 00000000,00000003
  groups: 00000000,00000002 00000000,00000001
  domain 1: span 00000000,00000003
   groups: 00000000,00000003
------------[ cut here ]------------
WARNING: at kernel/lockdep.c:2677 check_flags+0x84/0x11f()
Modules linked in:
Pid: 0, comm: swapper Not tainted 2.6.25-mm1 #15

Call Trace:
 [<ffffffff8105f7ec>] ? print_modules+0x88/0x8f
 [<ffffffff81037b55>] warn_on_slowpath+0x58/0x7f
 [<ffffffff81056143>] ? trace_hardirqs_off+0xd/0xf
 [<ffffffff810560b7>] ? trace_hardirqs_off_caller+0x1d/0x9c
 [<ffffffff81056143>] ? trace_hardirqs_off+0xd/0xf
 [<ffffffff810560b7>] ? trace_hardirqs_off_caller+0x1d/0x9c
 [<ffffffff81056143>] ? trace_hardirqs_off+0xd/0xf
 [<ffffffff81058576>] ? __lock_acquire+0x809/0x893
 [<ffffffff810560b7>] ? trace_hardirqs_off_caller+0x1d/0x9c
 [<ffffffff81056143>] ? trace_hardirqs_off+0xd/0xf
 [<ffffffff812b94d1>] ? __atomic_notifier_call_chain+0x0/0x81
 [<ffffffff8105627e>] check_flags+0x84/0x11f
 [<ffffffff81058914>] lock_acquire+0x54/0xb4
 [<ffffffff812b9515>] __atomic_notifier_call_chain+0x44/0x81
 [<ffffffff8100a2c2>] ? mwait_idle+0x0/0x49
 [<ffffffff812b9561>] atomic_notifier_call_chain+0xf/0x11
 [<ffffffff8100a228>] __exit_idle+0x27/0x29
 [<ffffffff8100b33c>] cpu_idle+0xdf/0xf7
 [<ffffffff812b10da>] start_secondary+0xb2/0xb4

---[ end trace 93d72a36b9146f22 ]---
possible reason: unannotated irqs-on.
irq event stamp: 34
hardirqs last  enabled at (33): [<ffffffff812b63f0>] trace_hardirqs_on_thunk+0x3a/0x3f
hardirqs last disabled at (34): [<ffffffff81056143>] trace_hardirqs_off+0xd/0xf
softirqs last  enabled at (32): [<ffffffff8103cfe8>] __do_softirq+0xc5/0xce
softirqs last disabled at (25): [<ffffffff8100d32c>] call_softirq+0x1c/0x28
calling  init_cpufreq_transition_notifier_list+0x0/0x1b()
initcall init_cpufreq_transition_notifier_list+0x0/0x1b() returned 0 after 0 msecs
calling  net_ns_init+0x0/0x12a()
net_namespace: 1352 bytes
initcall net_ns_init+0x0/0x12a() returned 0 after 0 msecs
calling  cpufreq_tsc+0x0/0x16()

dmesg: http://userweb.kernel.org/~akpm/x.txt
config: http://userweb.kernel.org/~akpm/config-t61p.txt

but it lumbered to a login prompt, which is more than good enough for this
pile of dung.

The number of runtime warnings, compile errors and runtime failures which
have been added since 2.6.25-rc8-mm2 is astonishing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 18 Apr 2008 00:57:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-mm1: not looking good
Message-Id: <20080418005733.aa3e8250.akpm@linux-foundation.org>
In-Reply-To: <20080418005323.7c015c42.akpm@linux-foundation.org>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
	<20080418005034.6e4dd9e7.akpm@linux-foundation.org>
	<20080418005323.7c015c42.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-pm@lists.linux-foundation.org, Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Apr 2008 00:53:23 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> oop, there's more:

I found another machine!  This one's an old 4-way Nocona (x86_64)

http://userweb.kernel.org/~akpm/config-x.txt
http://userweb.kernel.org/~akpm/dmesg-x.txt



CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU0: Thermal monitoring enabled (TM1)
ACPI: Core revision 20080321
Parsing all Control Methods:
Table [DSDT](id 0001) - 461 Objects with 50 Devices 130 Methods 11 Regions
 tbxface-0598 [00] tb_load_namespace     : ACPI Tables successfully acquired
evxfevnt-0091 [00] enable                : Transition to ACPI mode successful
------------[ cut here ]------------
WARNING: at arch/x86/kernel/genapic_64.c:86 read_apic_id+0x31/0x67()
Modules linked in:
Pid: 1, comm: swapper Not tainted 2.6.25-mm1 #16

Call Trace:
 [<ffffffff8025272f>] ? print_modules+0x88/0x8f
 [<ffffffff80233493>] warn_on_slowpath+0x58/0x81
 [<ffffffff80351ceb>] ? debug_spin_lock_after+0x18/0x1f
 [<ffffffff8035217a>] ? _raw_spin_lock+0x116/0x120
 [<ffffffff80228398>] ? sub_preempt_count+0x6d/0x74
 [<ffffffff804e9ba3>] ? _spin_unlock_irqrestore+0x33/0x40
 [<ffffffff803523e6>] ? debug_smp_processor_id+0x32/0xc4
 [<ffffffff8021ede5>] read_apic_id+0x31/0x67
 [<ffffffff8066f7f2>] verify_local_APIC+0xa7/0x163
 [<ffffffff8066e837>] native_smp_prepare_cpus+0x1ed/0x301
 [<ffffffff80669ab2>] kernel_init+0x5a/0x276
 [<ffffffff804e9a1e>] ? _spin_unlock_irq+0x2a/0x35
 [<ffffffff8022b7c2>] ? finish_task_switch+0x68/0x7f
 [<ffffffff8020c1d8>] child_rip+0xa/0x12
 [<ffffffff80669a58>] ? kernel_init+0x0/0x276
 [<ffffffff8020c1ce>] ? child_rip+0x0/0x12

---[ end trace 4eaa2a86a8e2da22 ]---
------------[ cut here ]------------
WARNING: at arch/x86/kernel/genapic_64.c:86 read_apic_id+0x31/0x67()
Modules linked in:
Pid: 1, comm: swapper Tainted: G        W 2.6.25-mm1 #16

Call Trace:
 [<ffffffff8025272f>] ? print_modules+0x88/0x8f
 [<ffffffff80233493>] warn_on_slowpath+0x58/0x81
 [<ffffffff80351ceb>] ? debug_spin_lock_after+0x18/0x1f
 [<ffffffff8035217a>] ? _raw_spin_lock+0x116/0x120
 [<ffffffff80228398>] ? sub_preempt_count+0x6d/0x74
 [<ffffffff804e9ba3>] ? _spin_unlock_irqrestore+0x33/0x40
 [<ffffffff803523e6>] ? debug_smp_processor_id+0x32/0xc4
 [<ffffffff8021ede5>] read_apic_id+0x31/0x67
 [<ffffffff8066f829>] verify_local_APIC+0xde/0x163
 [<ffffffff8066e837>] native_smp_prepare_cpus+0x1ed/0x301
 [<ffffffff80669ab2>] kernel_init+0x5a/0x276
 [<ffffffff804e9a1e>] ? _spin_unlock_irq+0x2a/0x35
 [<ffffffff8022b7c2>] ? finish_task_switch+0x68/0x7f
 [<ffffffff8020c1d8>] child_rip+0xa/0x12
 [<ffffffff80669a58>] ? kernel_init+0x0/0x276
 [<ffffffff8020c1ce>] ? child_rip+0x0/0x12

---[ end trace 4eaa2a86a8e2da22 ]---

That's

	WARN_ON(preemptible());

in read_apic_id().


Now I'll release it all.  heh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9E7396B00F3
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 22:29:08 -0400 (EDT)
Message-ID: <4F878F61.4020105@hitachi.com>
Date: Fri, 13 Apr 2012 11:28:49 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: Re: [PATCH UPDATED 3/3] tracing: Provide trace events interface
 for uprobes
References: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com> <20120409091154.8343.50489.sendpatchset@srdronam.in.ibm.com> <20120411103043.GB29437@linux.vnet.ibm.com> <4F86D264.9020004@hitachi.com> <20120412144927.GB21587@linux.vnet.ibm.com>
In-Reply-To: <20120412144927.GB21587@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

(2012/04/12 23:49), Srikar Dronamraju wrote:
>>> +
>>> +    # echo 'p /bin/zsh:0x46420 %ip %ax' > uprobe_events
>>> +
>>> +Please note: User has to explicitly calculate the offset of the probepoint
>>> +in the object. We can see the events that are registered by looking at the
>>> +uprobe_events file.
>>> +
>>> +    # cat uprobe_events
>>> +    p:uprobes/p_zsh_0x46420 /bin/zsh:0x0000000000046420
>>
>> Doesn't uprobe_events show the arguments of existing events?
>> And also, could you add an event format of above event here?
>>
> 
> [root@f14kvm tracing]#  cat uprobe_events 
> [root@f14kvm tracing]# echo 'p /bin/zsh:0x46420 %ip %ax' > uprobe_events 
> [root@f14kvm tracing]#  cat uprobe_events 
> p:uprobes/p_zsh_0x46420 /bin/zsh:0x00046420 arg1=%ip arg2=%ax
> [root@f14kvm tracing]#  cat events/uprobes/p_zsh_0x46420/format 
> name: p_zsh_0x46420
> ID: 922
> format:
>         field:unsigned short common_type;       offset:0;       size:2; signed:0;
>         field:unsigned char common_flags;       offset:2;       size:1; signed:0;
>         field:unsigned char common_preempt_count;       offset:3;       size:1; signed:0;
>         field:int common_pid;   offset:4;       size:4; signed:1;
>         field:int common_padding;       offset:8;       size:4; signed:1;
> 
>         field:unsigned long __probe_ip; offset:12;      size:4; signed:0;
>         field:u32 arg1; offset:16;      size:4; signed:0;
>         field:u32 arg2; offset:20;      size:4; signed:0;
> 
> print fmt: "(%lx) arg1=%lx arg2=%lx", REC->__probe_ip, REC->arg1, REC->arg2
> [root@f14kvm tracing]# 
> 
> Will update the Documentation file  with correct output of "cat
> uprobe_events". Do you want the format file to be added to the
> Documentation?

Yes, I want, please :)

Thank you!


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

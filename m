Message-ID: <48F83121.7070705@davidnewall.com>
Date: Fri, 17 Oct 2008 17:00:57 +1030
From: David Newall <davidn@davidnewall.com>
MIME-Version: 1.0
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>	<20081009124658.GE2952@elte.hu>	<1223557122.11830.14.camel@nimitz>	<20081009131701.GA21112@elte.hu>	<1223559246.11830.23.camel@nimitz>	<20081009134415.GA12135@elte.hu>	<1223571036.11830.32.camel@nimitz>	<20081010153951.GD28977@elte.hu>	<48F30315.1070909@fr.ibm.com>	<1223916223.29877.14.camel@nimitz>	<48F6092D.6050400@fr.ibm.com>	<48F685A3.1060804@cs.columbia.edu>	<48F7352F.3020700@fr.ibm.com>	<48F74674.20202@cs.columbia.edu> <87r66g8875.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87r66g8875.wl%peter@chubb.wattle.id.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrey Mirkin <major@openvz.org>
List-ID: <linux-mm.kvack.org>

Peter Chubb wrote:
>>>>>> "Oren" == Oren Laadan <orenl@cs.columbia.edu> writes:
>>>>>>             
>
> Oren> Daniel Lezcano wrote:
>
>   
>>>> The one exception (and it is a tedious one !) are states in which
>>>> the task is already frozen by definition: any ptrace blocking
>>>> point where the tracee waits for the tracer to grant permission to
>>>> proceed with its execution. Another example is in vfork(), waiting
>>>> for completion.
>>>>         
>>> I would say these are perfect places for "may be
>>> non-checkpointable" :)
>>>       
>
> Oren> For now, yes. But we definitely want this capability in the long
> Oren> run; otherwise we won't be able to checkpoint a kernel compile
> Oren> ('make' uses vfork), or anything with 'gdb' running inside, or
> Oren> 'strace', and other goodies.
>
> The strace/gdb example is *really* hard; but for vfork, you just wait
> until it's over. The interval between vfork and exec/exit should be
> short enough not to affect the overall time for a checkpoint

A malicious user could trivially exploit that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

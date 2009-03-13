Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9876B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 12:54:06 -0400 (EDT)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate3.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n2DGs2HH166412
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:54:02 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2DGs2we3309654
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:54:02 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2DGs1sI019338
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:54:02 GMT
Message-ID: <49BA8FA5.5030003@free.fr>
Date: Fri, 13 Mar 2009 17:53:57 +0100
From: Cedric Le Goater <legoater@free.fr>
MIME-Version: 1.0
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
 do?
References: <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226155755.GA1456@x200.localdomain> <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com> <49BA8013.3030103@free.fr> <20090313163531.GA10685@us.ibm.com>
In-Reply-To: <20090313163531.GA10685@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mingo@elte.hu, mpm@selenic.com, tglx@linutronix.de, torvalds@linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Serge E. Hallyn wrote:
> Quoting Cedric Le Goater (legoater@free.fr):
>>> No, what you're suggesting does not suffice.
>> probably. I'm still trying to understand what you mean below :)
>>
>> Man, I hate these hierarchicals pid_ns. one level would have been enough, 
>> just one vpid attribute in 'struct pid*'
> 
> Well I don't mind - temporarily - saying that nested pid namespaces
> are not checkpointable.  It's just that if we're going to need a new
> syscall anyway, then why not go ahead and address the whole problem?
> It's not hugely more complicated, and seems worth it.

yes. agree. there's a thread going on that topic. i'm following it.

[ ... ] 

>> anyway, I think that some CLONE_NEW* should be forbidden. Daniel should
>> send soon a little patch for the ns_cgroup restricting the clone flags
>> being used in a container.
> 
> Uh, that feels a bit over the top.  We want to make this
> uncheckpointable (if it remains so), not prevent the whole action.
> After all I may be running a container which I don't plan on ever
> checkpointing, and inside that container running a job which i do
> want to migrate.

ok. i've been scanning the emails a bit fast. that would be fine 
and useful.

> So depending on if we're doing the Dave or the rest-of-the-world
> way :), we either clear_bit(pidns->may_checkpoint) on the parent
> pid_ns when a child is created, or we walk every task being
> checkpointed and make sure they each are in the same pid_ns.  
> Doesn't that suffice?

yes. this 'may_checkpoint' is a container level info so I wonder 
where you store it. in a cgroup_checkpoint ? sorry for jumping in 
and may be restarting some old topics of discussion.

C.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

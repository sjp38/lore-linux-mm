Date: Wed, 20 Feb 2008 16:49:04 +0100 (CET)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
In-Reply-To: <47BC4554.10304@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0802201647060.26109@fbirervta.pbzchgretzou.qr>
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com>
 <18364.16552.455371.242369@stoffel.org> <47BC4554.10304@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: John Stoffel <john@stoffel.org>, Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Feb 20 2008 20:50, Balbir Singh wrote:
>John Stoffel wrote:
>> I know this is a pedantic comment, but why the heck is it called such
>> a generic term as "Memory Controller" which doesn't give any
>> indication of what it does.
>> 
>> Shouldn't it be something like "Memory Quota Controller", or "Memory
>> Limits Controller"?
>
>It's called the memory controller since it controls the amount of
>memory that a user can allocate (via limits). The generic term for
>any resource manager plugged into cgroups is a controller.

For ordinary desktop people, memory controller is what developers
know as MMU or sometimes even some other mysterious piece of silicon
inside the heavy box.

>If you look through some of the references in the document, we've
>listed our plans to support other categories of memory as well.
>Hence it's called a memory controller
>
>> Also, the Kconfig name "CGROUP_MEM_CONT" is just wrong, it should
>> be "CGROUP_MEM_CONTROLLER", just spell it out so it's clear what's
>> up.
>
>This has some history as well. Control groups was called containers
>earlier. That way a name like CGROUP_MEM_CONT could stand for cgroup
>memory container or cgroup memory controller.

CONT is shorthand for "continue" ;-) (SIGCONT, f.ex.), ctrl or ctrlr
it is for controllers (comes from Solaris iirc.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

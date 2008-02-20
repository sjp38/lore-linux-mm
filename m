MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18364.21039.360703.931967@stoffel.org>
Date: Wed, 20 Feb 2008 11:15:43 -0500
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
In-Reply-To: <47BC4554.10304@linux.vnet.ibm.com>
References: <20080220122338.GA4352@basil.nowhere.org>
	<47BC2275.4060900@linux.vnet.ibm.com>
	<18364.16552.455371.242369@stoffel.org>
	<47BC4554.10304@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: John Stoffel <john@stoffel.org>, Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Balbir" == Balbir Singh <balbir@linux.vnet.ibm.com> writes:

Balbir> John Stoffel wrote:
>> I know this is a pedantic comment, but why the heck is it called such
>> a generic term as "Memory Controller" which doesn't give any
>> indication of what it does.
>> 
>> Shouldn't it be something like "Memory Quota Controller", or "Memory
>> Limits Controller"?
>> 

Balbir> It's called the memory controller since it controls the amount
Balbir> of memory that a user can allocate (via limits).

Ding!  See how you mention limits here?  That should be part of the
generic term in the Kconfig to make it crystal clear what you mean by
a memory controller.

Balbir>  The generic term for any resource manager plugged into
Balbir> cgroups is a controller. 

The general term for managing resources is limits or quotas.  Not
controllers.  

Balbir> If you look through some of the references in the document,
Balbir> we've listed our plans to support other categories of memory
Balbir> as well. Hence it's called a memory controller

Still don't buy it, sorry.  :]

>> Also, the Kconfig name "CGROUP_MEM_CONT" is just wrong, it should be
>> "CGROUP_MEM_CONTROLLER", just spell it out so it's clear what's up.
>> 

Balbir> This has some history as well. Control groups was called
Balbir> containers earlier.  That way a name like CGROUP_MEM_CONT
Balbir> could stand for cgroup memory container or cgroup memory
Balbir> controller.

>> It took me a bunch of reading of Documentation/controllers/memory.txt
>> to even start to understand what the purpose of this was.  The
>> document could also use a re-writing to include a clear introduction
>> at the top to explain "what" a memory controller is.  
>> 
>> Something which talks about limits, resource management, quotas, etc
>> would be nice.  
>> 

Balbir> The references, specially reference [1] contains a lot of
Balbir> details on limits, guarantees, etc.  Since they've been
Balbir> documented in the past on lkml, I decided to keep them out of
Balbir> the documentation and mention them as references. If it's
Balbir> going to help to add that terminology; I can create another
Balbir> document describing what resource management means and what
Balbir> the commonly used terms mean.

Well, I think you need to first setup a new directory called
Documentation/cgroups/ and then you can put in an introduction.txt and
your controllers.txt files there.  

But controllers is just too generic a term.  For example, if I'm
talking about a controller on my desktop, does that mean I'm talking
about:

	SCSI, IDE, memory, USB, Firewire or serial ports?  

I've got all of them on my main system.  Again, I think you're
overloading a very generic term in a very non-obvious way and it needs
to be clarified for the regular developers and users.

Thanks,
John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

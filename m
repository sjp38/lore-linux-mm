Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E1BAA6B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 17:32:21 -0500 (EST)
Message-ID: <496E67DA.7050503@cs.columbia.edu>
Date: Wed, 14 Jan 2009 17:31:54 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v12][PATCH 01/14] Create syscalls: sys_checkpoint,	sys_restart
References: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu> <1230542187-10434-2-git-send-email-orenl@cs.columbia.edu> <20090114180441.GD21516@balbir.in.ibm.com>
In-Reply-To: <20090114180441.GD21516@balbir.in.ibm.com>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Mike Waychison <mikew@google.com>
List-ID: <linux-mm.kvack.org>



Balbir Singh wrote:
> * Oren Laadan <orenl@cs.columbia.edu> [2008-12-29 04:16:14]:
> 
>> Create trivial sys_checkpoint and sys_restore system calls. They will
>> enable to checkpoint and restart an entire container, to and from a
>> checkpoint image file descriptor.
>>
>> The syscalls take a file descriptor (for the image file) and flags as
>> arguments. For sys_checkpoint the first argument identifies the target
>> container; for sys_restart it will identify the checkpoint image.
>>
>> A checkpoint, much like a process coredump, dumps the state of multiple
>> processes at once, including the state of the container. The checkpoint
>> image is written to (and read from) the file descriptor directly from
>> the kernel. This way the data is generated and then pushed out naturally
>> as resources and tasks are scanned to save their state. This is the
>> approach taken by, e.g., Zap and OpenVZ.
>>
>> By using a return value and not a file descriptor, we can distinguish
>> between a return from checkpoint, a return from restart (in case of a
>> checkpoint that includes self, i.e. a task checkpointing its own
>> container, or itself), and an error condition, in a manner analogous
>> to a fork() call.
>>
>> We don't use copyin()/copyout() because it requires holding the entire
> 
>               ^^^^^^^^^^^^^^^^^^^ Do you mean get_user_pages(),
> copy_to/from_user()?

Yes, I meant copy_to/from_user() ...

Oren.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

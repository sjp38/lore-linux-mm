Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B8C036B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 03:20:40 -0500 (EST)
Date: Thu, 28 Jan 2010 00:18:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Security] DoS on x86_64
Message-Id: <20100128001802.8491e8c1.akpm@linux-foundation.org>
In-Reply-To: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mathias Krause <minipli@googlemail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, security@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Mike Waychison <mikew@google.com>Thomas Gleixner <tglx@linutronix.de>, Michael Davidson <md@google.com>, "Luck, Tony" <tony.luck@intel.com>, Roland McGrath <roland@redhat.com>, James Morris <jmorris@namei.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 2010 08:34:02 +0100 Mathias Krause <minipli@googlemail.com> wrote:

> I found by accident an reliable way to panic the kernel on an x86_64  
> system. Since this one can be triggered by an unprivileged user I  
> CCed security@kernel.org. I also haven't found a corresponding bug on  
> bugzilla.kernel.org. So, what to do to trigger the bug:
> 
> 1. Enable core dumps
> 2. Start an 32 bit program that tries to execve() an 64 bit program
> 3. The 64 bit program cannot be started by the kernel because it  
> can't find the interpreter, i.e. execve returns with an error
> 4. Generate a segmentation fault
> 5. panic

hrm, isn't this the same as "failed exec() leaves caller with incorrect
personality", discussed in December? afacit nothing happened as a result
of that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

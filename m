Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3896B0083
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 18:48:14 -0500 (EST)
Date: Thu, 28 Jan 2010 15:46:54 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] DoS on x86_64
In-Reply-To: <4B621D48.4090203@zytor.com>
Message-ID: <alpine.LFD.2.00.1001281545190.3800@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain> <4B62141E.4050107@zytor.com>
 <alpine.LFD.2.00.1001281507080.3846@localhost.localdomain> <4B621D48.4090203@zytor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Mathias Krause <minipli@googlemail.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>



On Thu, 28 Jan 2010, H. Peter Anvin wrote:
> 
> I think your splitup patch might still be a good idea in the sense that
> your flush_old_exec() is the parts that can fail.

Yeah. And it does have the advantage that then the naming really matches 
what it does.

Side note: my splitup was purely by "can fail"/"cannot fail", it wasn't 
really by "flush old"/"setup new". So the split could certainly be done 
better, even if from a practical perspective it probably doesn't much 
matter.

> So I think the splitup patch, plus removing delayed effects, might be
> the right thing to do?  Testing that approach now...

Ok, thanks.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

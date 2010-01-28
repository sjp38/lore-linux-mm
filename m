Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 46AE36B0096
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 18:27:58 -0500 (EST)
Message-ID: <4B621D48.4090203@zytor.com>
Date: Thu, 28 Jan 2010 15:27:04 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [Security] DoS on x86_64
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain> <4B62141E.4050107@zytor.com> <alpine.LFD.2.00.1001281507080.3846@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.1001281507080.3846@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Mathias Krause <minipli@googlemail.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 01/28/2010 03:09 PM, Linus Torvalds wrote:
> 
> 
> On Thu, 28 Jan 2010, H. Peter Anvin wrote:
>>
>> So this patch, *plus* removing any delayed side effects from
>> SET_PERSONALITY() [e.g. the TIF_ABI_PENDING stuff in x86-64 which is
>> intended to have a forward action from SET_PERSONALITY() to
>> flush_thread()] might just work.  I will try it out.
> 
> Yeah, if you do that, then my "split up" patch isn't necessary. And it 
> would make the code a whole lot more straightforward, and remove that 
> whole crazy TIF_ABI_PENDING thing.
> 
> Getting rid of the whole TIF_ABI_PENDING crap would be wonderful. It would 
> make SET_PERSONALITY() (and flush_thread()) way more obvious. 
> 
> So that would be much better than the untested "split up flush_old_exec" 
> patch I just sent out. So forget that patch, and let's go with your 
> further cleanup approach instead.
> 

I think your splitup patch might still be a good idea in the sense that
your flush_old_exec() is the parts that can fail.

So I think the splitup patch, plus removing delayed effects, might be
the right thing to do?  Testing that approach now...

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

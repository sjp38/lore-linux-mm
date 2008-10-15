Received: by gxk8 with SMTP id 8so5938840gxk.14
        for <linux-mm@kvack.org>; Wed, 15 Oct 2008 08:33:47 -0700 (PDT)
Message-ID: <48F60D56.6040209@gmail.com>
Date: Wed, 15 Oct 2008 17:33:42 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: GIT head no longer boots on x86-64
References: <alpine.LFD.2.00.0810130752020.3288@nehalem.linux-foundation.org> <1223910693-28693-1-git-send-email-jirislaby@gmail.com> <20081013164717.7a21084a@lxorguk.ukuu.org.uk> <20081015115153.GA16413@elte.hu> <alpine.LFD.2.00.0810150758310.3288@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0810150758310.3288@nehalem.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/15/2008 05:06 PM, Linus Torvalds wrote:
> On Wed, 15 Oct 2008, Ingo Molnar wrote:
>> Queued the fix below up in tip/x86/urgent for a merge to Linus later 
>> today. Thanks!
> 
> Please don't send this crap to me.
> 
> Guys, _look_ at the patch for one second. And then tell me it isn't crap. 

Not in my eyes.

> The question is: "Is this a vmalloc'ed area?". That's the name of the 
> function. AND YOU JUST BROKE IT!

Modules area is vmalloc'ed on x86; on x86_64 only in different virtual address
space area. So returning true from is_vmalloc_addr() for this space looks very
sane to me, as it was on x86_32 for years.

Users usually do
is_vmalloc_addr(a) ? vfree(a) : kfree(a);
Even there it makes more sense to me.

However I'm fine with introducing is_module_addr() alike function for x86 to
check the general modules space bounds on x86_64 and return is_vmalloc_addr() on
x86_32. Does this look better?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

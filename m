Date: Wed, 15 Oct 2008 08:06:13 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: GIT head no longer boots on x86-64
In-Reply-To: <20081015115153.GA16413@elte.hu>
Message-ID: <alpine.LFD.2.00.0810150758310.3288@nehalem.linux-foundation.org>
References: <alpine.LFD.2.00.0810130752020.3288@nehalem.linux-foundation.org> <1223910693-28693-1-git-send-email-jirislaby@gmail.com> <20081013164717.7a21084a@lxorguk.ukuu.org.uk> <20081015115153.GA16413@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jiri Slaby <jirislaby@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 15 Oct 2008, Ingo Molnar wrote:
> 
> Queued the fix below up in tip/x86/urgent for a merge to Linus later 
> today. Thanks!

Please don't send this crap to me.

Guys, _look_ at the patch for one second. And then tell me it isn't crap. 

The question is: "Is this a vmalloc'ed area?". That's the name of the 
function. AND YOU JUST BROKE IT!

Fix the damn caller instead. Don't make x86-64-specific changes to a 
generic function that breaks the whole meaning of the function. I don't 
understand what the hell is wrong with you people - we don't fix bugs by 
introducing idiocies, we fix them by fixing the code.

EVEN YOUR COMMIT MESSAGE should have made this obvious.

The code in question already does

	VIRTUAL_BUG_ON(!is_vmalloc_addr(vmalloc_addr) &&
                       !is_module_address(addr));

and look at that thing and ask yourself: where was the bug again.

And dammit, if you say it was in "is_vmalloc_addr()", I can only shake my 
head.

Please guys. Use some taste. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

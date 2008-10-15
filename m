Date: Wed, 15 Oct 2008 13:51:53 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: GIT head no longer boots on x86-64
Message-ID: <20081015115153.GA16413@elte.hu>
References: <alpine.LFD.2.00.0810130752020.3288@nehalem.linux-foundation.org> <1223910693-28693-1-git-send-email-jirislaby@gmail.com> <20081013164717.7a21084a@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081013164717.7a21084a@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jiri Slaby <jirislaby@gmail.com>, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > I guess SMP kernel running on UP? In such a case the module .text
> 
> Yep
> 
> > is patched to use UP locks before the module is added to the modules
> > list and it thinks there are no valid data at that place while
> > patching.
> > 
> > Could you test it? The bug disappeared here in qemu. I've checked
> > callers of the function, and it should not matter for them.
> 
> Seems to do the job.

Queued the fix below up in tip/x86/urgent for a merge to Linus later 
today. Thanks!

	Ingo

------------------>

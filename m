Date: Mon, 13 Oct 2008 16:47:17 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: GIT head no longer boots on x86-64
Message-ID: <20081013164717.7a21084a@lxorguk.ukuu.org.uk>
In-Reply-To: <1223910693-28693-1-git-send-email-jirislaby@gmail.com>
References: <alpine.LFD.2.00.0810130752020.3288@nehalem.linux-foundation.org>
	<1223910693-28693-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I guess SMP kernel running on UP? In such a case the module .text

Yep

> is patched to use UP locks before the module is added to the modules
> list and it thinks there are no valid data at that place while
> patching.
> 
> Could you test it? The bug disappeared here in qemu. I've checked
> callers of the function, and it should not matter for them.

Seems to do the job.

Jiri 1 Linus 0

;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

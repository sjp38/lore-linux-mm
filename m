Date: Thu, 3 Mar 2005 10:59:46 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: RFC: Speed freeing memory for suspend.
Message-ID: <20050303095946.GA1445@elf.ucw.cz>
References: <1109812166.3733.3.camel@desktop.cunningham.myip.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1109812166.3733.3.camel@desktop.cunningham.myip.net.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@cyclades.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

> Here's a patch I've prepared which improves the speed at which memory is
> freed prior to suspend. It should be a big gain for swsusp. For
> suspend2, it isn't used much, but has shown big improvements when I set
> a very low image size limit and had memory quite full.

It looks good to me.
								Pavel

-- 
People were complaining that M$ turns users into beta-testers...
...jr ghea gurz vagb qrirybcref, naq gurl frrz gb yvxr vg gung jnl!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

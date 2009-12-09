Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1E0BC60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 12:09:28 -0500 (EST)
Received: from chimera.site ([96.253.169.185]) by xenotime.net for <linux-mm@kvack.org>; Wed, 9 Dec 2009 09:09:22 -0800
Date: Wed, 9 Dec 2009 09:09:21 -0800
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for December 9 (hwpoison)
Message-Id: <20091209090921.a3293706.rdunlap@xenotime.net>
In-Reply-To: <20091209174738.3b8c28a6.sfr@canb.auug.org.au>
References: <20091209174738.3b8c28a6.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stephen Rothwell <sfr@canb.auug.org.au>, Andi Kleen <andi@firstfloor.org>
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Dec 2009 17:47:38 +1100 Stephen Rothwell wrote:

> Hi all,
> 
> My usual call for calm: please do not put stuff destined for 2.6.34 into
> linux-next trees until after 2.6.33-rc1.
> 
> Changes since 20091208:
> 
> 
> The hwpoison tree lost its build failure.


CONFIG_PROC_PAGE_MONITOR is not enabled:


mm/built-in.o: In function `hwpoison_filter':
(.text+0x43cce): undefined reference to `stable_page_flags'

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

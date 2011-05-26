Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8666B0022
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:44:03 -0400 (EDT)
Received: by ewy9 with SMTP id 9so518417ewy.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 11:43:59 -0700 (PDT)
Date: Thu, 26 May 2011 21:44:02 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] mm: don't access vm_flags as 'int'
Message-ID: <20110526184402.GA2453@p183.telecom.by>
References: <4DDE2873.7060409@jp.fujitsu.com>
 <BANLkTi=znC18PAbpDfeVO+=Pat_EeXddjw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTi=znC18PAbpDfeVO+=Pat_EeXddjw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com

On Thu, May 26, 2011 at 10:53:34AM -0700, Linus Torvalds wrote:
> 2011/5/26 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> > The type of vma->vm_flags is 'unsigned long'. Neither 'int' nor
> > 'unsigned int'. This patch fixes such misuse.
> 
> I applied this, except I also just made the executive decision to
> replace things with "vm_flags_t" after all.

Woo-hoo!

Why it is marked __nocast and not __bitwise__ like gfp_t?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

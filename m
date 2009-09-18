Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 85BA06B00AD
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 04:00:33 -0400 (EDT)
Date: Fri, 18 Sep 2009 08:59:40 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
In-Reply-To: <1253260528.4959.13.camel@penberg-laptop>
Message-ID: <Pine.LNX.4.64.0909180857170.5404@sister.anvils>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
 <1253227412-24342-3-git-send-email-ngupta@vflare.org>
 <1253256805.4959.8.camel@penberg-laptop>  <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
 <1253260528.4959.13.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 18 Sep 2009, Pekka Enberg wrote:
> 
> The *hook* looks OK to me but set_swap_free_notify() looks like an ugly
> hack. I don't understand why we're setting up the hook lazily in
> ramzswap_read() nor do I understand why we need to look up struct
> swap_info_struct with a bdev. Surely there's a cleaner way to do all
> this? Probably somewhere in sys_swapon()?

Sounds like you have something in mind, may well be better,
but please show us a patch...  (my mind is elsewhere!)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

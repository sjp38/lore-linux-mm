Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8AEF36B00C9
	for <linux-mm@kvack.org>; Wed, 13 May 2009 04:31:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4D8Vvem016971
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 May 2009 17:31:57 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0162F45DE53
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:31:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CF45545DE50
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:31:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B8F9F1DB803E
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:31:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 54D4EE18002
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:31:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] Replace the watermark-related union in struct zone with a watermark[] array V2
In-Reply-To: <20090512141331.GI25923@csn.ul.ie>
References: <1241099300.29485.96.camel@nimitz> <20090512141331.GI25923@csn.ul.ie>
Message-Id: <20090513173138.7237.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 May 2009 17:31:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Changelog since V1
>   o Use N_wmark_pages accessors instead of array accesses
> 
> Patch page-allocator-use-allocation-flags-as-an-index-to-the-zone-watermark
> from -mm added a union to struct zone where the watermarks could be accessed
> with either zone->pages_* or a pages_mark array. The concern was that this
> aliasing caused more confusion that it helped.
> 
> This patch replaces the union with a watermark array that is indexed with
> WMARK_* defines accessed via helpers. All call sites that use zone->pages_*
> are updated to use the helpers for accessing the values and the array
> offsets for setting.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

looks good to me :)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

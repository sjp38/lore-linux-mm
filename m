Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 151FB6B0201
	for <linux-mm@kvack.org>; Thu, 13 May 2010 04:06:22 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D86KWA010534
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 13 May 2010 17:06:20 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 005D245DE7A
	for <linux-mm@kvack.org>; Thu, 13 May 2010 17:06:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CEBE945DE6F
	for <linux-mm@kvack.org>; Thu, 13 May 2010 17:06:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B3FADE08005
	for <linux-mm@kvack.org>; Thu, 13 May 2010 17:06:19 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 65096E08001
	for <linux-mm@kvack.org>; Thu, 13 May 2010 17:06:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Cleanup migrate case in try_to_unmap_one
In-Reply-To: <4BEBA70C.9050404@vflare.org>
References: <20100513144336.216D.A69D9226@jp.fujitsu.com> <4BEBA70C.9050404@vflare.org>
Message-Id: <20100513163441.2176.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 13 May 2010 17:06:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On 05/13/2010 11:34 AM, KOSAKI Motohiro wrote:
> >> Remove duplicate handling of TTU_MIGRATE case for
> >> anonymous and filesystem pages.
> >>
> >> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> > 
> > This patch change swap cache case. I think this is not intentional.
> 
> IIUC, we never call this function with TTU_MIGRATE for swap cache pages.
> So, the behavior after this patch remains unchanged.

Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

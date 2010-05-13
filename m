Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5B4F06B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 23:36:16 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D3aEA9029333
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 13 May 2010 12:36:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 232A445DE51
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:36:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 08F0945DE4C
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:36:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E67F2E08003
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:36:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A11AAE08004
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:36:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 5/5] vmscan: remove may_swap scan control
In-Reply-To: <20100430224316.198324471@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org> <20100430224316.198324471@cmpxchg.org>
Message-Id: <20100513122935.2161.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 13 May 2010 12:36:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The may_swap scan control flag can be naturally merged into the
> swappiness parameter: swap only if swappiness is non-zero.

Sorry, NAK.

AFAIK, swappiness==0 is very widely used in MySQL users community.
They expect this parameter mean "very prefer to discard file cache 
rather than swap, but not completely disable swap".

We shouldn't ignore the real world use case. even if it is a bit strange.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

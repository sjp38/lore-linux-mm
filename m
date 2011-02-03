Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0CDA98D0039
	for <linux-mm@kvack.org>; Wed,  2 Feb 2011 19:57:38 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A5E5A3EE0B3
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:57:35 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A2DC45DE5B
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:57:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 70C6C45DE59
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:57:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A750E08002
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:57:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 129951DB8037
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:57:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mlock: operate on any regions with protection != PROT_NONE
In-Reply-To: <4D48498A.9040606@redhat.com>
References: <20110201010341.GA21676@google.com> <4D48498A.9040606@redhat.com>
Message-Id: <20110203095757.939F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu,  3 Feb 2011 09:57:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tao Ma <tm@tao.ma>, Hugh Dickins <hughd@google.com>

> On 01/31/2011 08:03 PM, Michel Lespinasse wrote:
> > As Tao Ma noticed, change 5ecfda0 breaks blktrace. This is because
> > blktrace mmaps a file with PROT_WRITE permissions but without PROT_READ,
> > so my attempt to not unnecessarity break COW during mlock ended up
> > causing mlock to fail with a permission problem.
> >
> > I am proposing to let mlock ignore vma protection in all cases except
> > PROT_NONE. In particular, mlock should not fail for PROT_WRITE regions
> > (as in the blktrace case, which broke at 5ecfda0) or for PROT_EXEC
> > regions (which seem to me like they were always broken).
> >
> > Please review. I am proposing this as a candidate for 2.6.38 inclusion,
> > because of the behavior change with blktrace.
> 
> Acked-by: Rik van Riel <riel@redhat.com>

Reviewed-by :KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

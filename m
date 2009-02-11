Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A27916B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 18:53:36 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1BNrXkd020982
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 12 Feb 2009 08:53:34 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BAE5F45DD7B
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 08:53:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 951DA45DD78
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 08:53:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 839E51DB803B
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 08:53:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 439361DB8037
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 08:53:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmalloc: Add __get_vm_area_caller()
In-Reply-To: <20090211144509.d22feeb8.akpm@linux-foundation.org>
References: <20090211171804.7021.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090211144509.d22feeb8.akpm@linux-foundation.org>
Message-Id: <20090212085156.C8DB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 12 Feb 2009 08:53:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, benh@kernel.crashing.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Wed, 11 Feb 2009 17:22:47 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > I want to put into powerpc-next patches relying into that, so if the
> > > patch is ok with you guys, can I stick it in powerpc.git ?
> > 
> > hm.
> > Generally, all MM patch should merge into -mm tree at first.
> > but I don't think this patch have conflict risk. 
> > 
> > Andrew, What do you think?
> 
> We can sneak it into mainline later in the week?

I think this patch obiously doesn't have any regression risk.
I obey your judgement.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

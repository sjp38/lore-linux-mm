Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1BE6B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 17:45:44 -0500 (EST)
Date: Wed, 11 Feb 2009 14:45:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmalloc: Add __get_vm_area_caller()
Message-Id: <20090211144509.d22feeb8.akpm@linux-foundation.org>
In-Reply-To: <20090211171804.7021.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090211044854.969CEDDDA9@ozlabs.org>
	<20090211171804.7021.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Feb 2009 17:22:47 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > I want to put into powerpc-next patches relying into that, so if the
> > patch is ok with you guys, can I stick it in powerpc.git ?
> 
> hm.
> Generally, all MM patch should merge into -mm tree at first.
> but I don't think this patch have conflict risk. 
> 
> Andrew, What do you think?

We can sneak it into mainline later in the week?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

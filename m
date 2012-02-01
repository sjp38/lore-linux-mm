Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 99F156B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 17:43:42 -0500 (EST)
Date: Wed, 1 Feb 2012 14:43:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] hugetlbfs: fix hugetlb_get_unmapped_area
Message-Id: <20120201144340.01b3d050.akpm@linux-foundation.org>
In-Reply-To: <4F2784BE.9090600@linux.vnet.ibm.com>
References: <4F101904.8090405@linux.vnet.ibm.com>
	<4F2784BE.9090600@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 31 Jan 2012 14:05:50 +0800
Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com> wrote:

> On 01/13/2012 07:44 PM, Xiao Guangrong wrote:
> 
> > Using/updating cached_hole_size and free_area_cache properly to speedup
> > find free region
> > 
> 
> 
> Ping...???

I'd saved the patches away, hoping that someone who works on hugetlb
would comment.  They didn't.  We haven't heard from wli in a long time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

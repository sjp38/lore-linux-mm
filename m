Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1FF6B005D
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 20:46:19 -0400 (EDT)
Date: Thu, 17 Sep 2009 17:46:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] Add MAP_HUGETLB for mmaping pseudo-anonymous huge
 page regions
Message-Id: <20090917174616.f64123fb.akpm@linux-foundation.org>
In-Reply-To: <20090917154404.e1d3694e.akpm@linux-foundation.org>
References: <cover.1251197514.git.ebmunson@us.ibm.com>
	<25614b0d0581e2d49e1024dc1671b282f193e139.1251197514.git.ebmunson@us.ibm.com>
	<8504342f7be19e416ef769d1edd24b8549f8dc39.1251197514.git.ebmunson@us.ibm.com>
	<20090917154404.e1d3694e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ebmunson@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, rth@twiddle.net, ink@jurassic.park.msu.ru
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 15:44:04 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> mm/mmap.c: In function 'do_mmap_pgoff':
> mm/mmap.c:953: error: 'MAP_HUGETLB' undeclared (first use in this function)

mips breaks as well.

I don't know how many other architectures broke.  I disabled the patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

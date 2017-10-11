Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 710506B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 12:51:15 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j3so4886632pga.3
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:51:15 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id i17si6627810pfk.579.2017.10.11.09.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 09:51:13 -0700 (PDT)
Date: Wed, 11 Oct 2017 09:51:11 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 0/7 v1] Speed up page cache truncation
Message-ID: <20171011165111.GG5109@tassilo.jf.intel.com>
References: <20171010151937.26984-1-jack@suse.cz>
 <878tgisyo6.fsf@linux.intel.com>
 <20171011080658.GK3667@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011080658.GK3667@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

> > It's odd that just checking if some pages are huge should be that
> > expensive, but ok ..
> 
> Yeah, I was surprised as well but profiles were pretty clear on this - part
> of the slowdown was caused by loads of page->_compound_head (PageTail()
> and page_compound() use that) which we previously didn't have to load at
> all, part was in hpage_nr_pages() function and its use.

A strategic early prefetch may help.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

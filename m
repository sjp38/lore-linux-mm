Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 11CC46B0007
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 09:10:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g63-v6so13536823pfc.9
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 06:10:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m63-v6si19761329pld.379.2018.10.18.06.10.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Oct 2018 06:10:50 -0700 (PDT)
Date: Thu, 18 Oct 2018 06:10:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: get pfn by page_to_pfn() instead of save in
 page->private
Message-ID: <20181018131046.GA32429@bombadil.infradead.org>
References: <20181018130429.37837-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018130429.37837-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, mgorman@techsingularity.net, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 09:04:29PM +0800, Wei Yang wrote:
> This is not necessary to save the pfn to page->private.
> 
> The pfn could be retrieved by page_to_pfn() directly.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
> Maybe I missed some critical reason to save pfn to private.
> 
> Thanks in advance if someone could reveal the special reason.

Performance.  Did you benchmark this?

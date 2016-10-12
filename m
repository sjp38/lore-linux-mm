Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3CE16B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:36:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r16so38348630pfg.4
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:36:47 -0700 (PDT)
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com. [209.85.192.182])
        by mx.google.com with ESMTPS id x199si5233296pgx.295.2016.10.12.03.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 03:36:47 -0700 (PDT)
Received: by mail-pf0-f182.google.com with SMTP id e6so16631007pfk.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:36:47 -0700 (PDT)
Date: Wed, 12 Oct 2016 12:36:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: page_alloc: Use KERN_CONT where appropriate
Message-ID: <20161012103643.GJ17128@dhcp22.suse.cz>
References: <c7df37c8665134654a17aaeb8b9f6ace1d6db58b.1476239034.git.joe@perches.com>
 <20161012091013.GB9523@dhcp22.suse.cz>
 <1476266250.16823.3.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476266250.16823.3.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: inux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Wed 12-10-16 02:57:30, Joe Perches wrote:
[...]
> This recent change to printk logging making KERN_CONT necessary to
> continue a line might be reverted when it's better known just how
> many instances in the kernel tree will need to be changed.

OK, I will wait until this settles.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

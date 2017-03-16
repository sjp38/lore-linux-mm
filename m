Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD1D86B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:58:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u108so7722751wrb.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:58:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si6185385wra.84.2017.03.16.03.58.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 03:58:29 -0700 (PDT)
Date: Thu, 16 Mar 2017 11:58:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm: page_alloc: Break up a long single-line printk
Message-ID: <20170316105828.GD30508@dhcp22.suse.cz>
References: <cover.1489628459.git.joe@perches.com>
 <3ceb85654e0cfe5168cc36f96a6e09822cf7139e.1489628459.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ceb85654e0cfe5168cc36f96a6e09822cf7139e.1489628459.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 15-03-17 18:43:15, Joe Perches wrote:
> Blocked multiple line output is easier to read than an
> extremely long single line.

I am not really sure this is an improvemnt. If anything add an output
before and after to the changelog.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

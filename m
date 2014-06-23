Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 56C936B004D
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 07:19:21 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id q58so6744957wes.2
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 04:19:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9si1417473wia.68.2014.06.23.04.19.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 04:19:17 -0700 (PDT)
Date: Mon, 23 Jun 2014 12:19:14 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm:kswapd: clean up the kswapd
Message-ID: <20140623111914.GK10819@suse.de>
References: <1403500494-5110-1-git-send-email-slaoub@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1403500494-5110-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 23, 2014 at 01:14:54PM +0800, Chen Yucong wrote:
> According to the commit 215ddd66 (mm: vmscan: only read new_classzone_idx from
> pgdat when reclaiming successfully) and the commit d2ebd0f6b (kswapd: avoid
> unnecessary rebalance after an unsuccessful balancing), we can use a boolean
> variable for replace balanced_* variables, which makes the kswapd more clarify.
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>

I think this is just churning code for the sake of it. It's not any
easier to understand as a result of the modification and does not appear
to be a preparation for a follow-on patch that addresses a bug.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

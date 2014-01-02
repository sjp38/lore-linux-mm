Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id 75EAE6B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 10:57:30 -0500 (EST)
Received: by mail-ea0-f175.google.com with SMTP id z10so6351909ead.34
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 07:57:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s42si66358470eew.203.2014.01.02.07.57.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 07:57:29 -0800 (PST)
Date: Thu, 2 Jan 2014 15:57:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: page_alloc: use enum instead of number for
 migratetype
Message-ID: <20140102155726.GA865@suse.de>
References: <1388661922-10957-1-git-send-email-sj38.park@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1388661922-10957-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 02, 2014 at 08:25:22PM +0900, SeongJae Park wrote:
> Using enum instead of number for migratetype everywhere would be better
> for reading and understanding.
> 
> Signed-off-by: SeongJae Park <sj38.park@gmail.com>

This implicitly makes assumptions about the value of MIGRATE_UNMOVABLE
and does not appear to actually fix or improve anything.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

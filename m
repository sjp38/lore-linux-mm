Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F353C8E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 11:17:49 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c34so1370589edb.8
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 08:17:49 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9-v6si847798ejd.284.2018.12.13.08.17.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 08:17:48 -0800 (PST)
Date: Thu, 13 Dec 2018 17:17:46 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/6] mm: migrate: Drop unused argument of
 migrate_page_move_mapping()
Message-ID: <20181213161746.GB27517@quack2.suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-7-jack@suse.cz>
 <20181213153543.GF28934@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181213153543.GF28934@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mhocko@suse.cz, Andrew Morton <akpm@linux-foundation.org>

On Thu 13-12-18 15:35:43, Mel Gorman wrote:
> On Tue, Dec 11, 2018 at 06:21:43PM +0100, Jan Kara wrote:
> > All callers of migrate_page_move_mapping() now pass NULL for 'head'
> > argument. Drop it.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks for review Mel! Andrew, can you please pick up the series? Thanks!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

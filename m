Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 45B418E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:17:17 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id m3so11834645pfj.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:17:17 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c8si11550160pfe.243.2018.12.17.05.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 05:17:16 -0800 (PST)
Date: Mon, 17 Dec 2018 14:17:10 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/6] mm: migrate: Drop unused argument of
 migrate_page_move_mapping()
Message-ID: <20181217131710.GB8611@quack2.suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-7-jack@suse.cz>
 <20181213153543.GF28934@suse.de>
 <20181213161746.GB27517@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Content-Disposition: inline
In-Reply-To: <20181213161746.GB27517@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mhocko@suse.cz, Mel Gorman <mgorman@suse.de>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu 13-12-18 17:17:46, Jan Kara wrote:
> On Thu 13-12-18 15:35:43, Mel Gorman wrote:
> > On Tue, Dec 11, 2018 at 06:21:43PM +0100, Jan Kara wrote:
> > > All callers of migrate_page_move_mapping() now pass NULL for 'head'
> > > argument. Drop it.
> > > 
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > 
> > Acked-by: Mel Gorman <mgorman@suse.de>
> 
> Thanks for review Mel! Andrew, can you please pick up the series? Thanks!

Andrew, Mel has spotted a bug in patch 1/6 or this series. Can you please
add the attached fixup to the patch 1? Thanks!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--MGYHOYXEY6WxJCY8
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="migratepage-fixup.patch"

diff --git a/mm/migrate.c b/mm/migrate.c
index 789c7bc90a0c..816ce10e908f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -438,7 +438,7 @@ static int expected_page_refs(struct page *page)
 	 */
 	expected_count += is_device_private_page(page);
 	expected_count += is_device_public_page(page);
-	if (page->mapping)
+	if (page_mapping(page))
 		expected_count += hpage_nr_pages(page) + page_has_private(page);
 
 	return expected_count;

--MGYHOYXEY6WxJCY8--

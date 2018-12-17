Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 077968E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:11:05 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so8527862edt.23
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:11:04 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s12-v6si1413764ejk.286.2018.12.17.05.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 05:11:02 -0800 (PST)
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 03EECACBC
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 13:11:02 +0000 (UTC)
Date: Mon, 17 Dec 2018 14:11:00 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/6] mm: migration: Factor out code to compute expected
 number of page references
Message-ID: <20181217131100.GA8611@quack2.suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-2-jack@suse.cz>
 <20181214151045.GG28934@suse.de>
 <20181214155311.GG8896@quack2.suse.cz>
 <20181214162428.GH28934@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214162428.GH28934@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mhocko@suse.cz

On Fri 14-12-18 16:24:28, Mel Gorman wrote:
> On Fri, Dec 14, 2018 at 04:53:11PM +0100, Jan Kara wrote:
> > > This page->mapping test is relevant for the "Anonymous page without
> > > mapping" check but I think it's wrong. An anonymous page without mapping
> > > doesn't have a NULL mapping, it sets PAGE_MAPPING_ANON and the field can
> > > be special in other ways. I think you meant to use page_mapping(page)
> > > here, not page->mapping?
> > 
> > Yes, that's a bug. It should have been page_mapping(page). Thanks for
> > catching this.
> > 
> 
> My pleasure, should have spotted it the first time around :/

And after fixing this, I can see the success rates for
global-dhp__workload_thpscale-madvhugepage to go back to the original
values. So that was indeed the problem. I'll send the fixup to Andrew.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

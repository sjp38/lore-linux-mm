Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0D08A8E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 10:35:00 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so1296154edm.18
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 07:34:59 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si920426eda.325.2018.12.13.07.34.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 07:34:58 -0800 (PST)
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ED7EFADD7
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 15:34:57 +0000 (UTC)
Date: Thu, 13 Dec 2018 15:34:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/6] mm: migrate: Provide buffer_migrate_page_norefs()
Message-ID: <20181213153456.GD28934@suse.de>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-5-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181211172143.7358-5-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mhocko@suse.cz

On Tue, Dec 11, 2018 at 06:21:41PM +0100, Jan Kara wrote:
> Provide a variant of buffer_migrate_page() that also checks whether
> there are no unexpected references to buffer heads. This function will
> then be safe to use for block device pages.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

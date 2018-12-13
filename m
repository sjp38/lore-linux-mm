Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB6468E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 09:57:31 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i14so1254781edf.17
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 06:57:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c47si1008384eda.167.2018.12.13.06.57.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 06:57:30 -0800 (PST)
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4344FAD5C
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 14:57:30 +0000 (UTC)
Date: Thu, 13 Dec 2018 14:57:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/6] mm: migrate: Move migrate_page_lock_buffers()
Message-ID: <20181213145728.GC28934@suse.de>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-4-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181211172143.7358-4-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mhocko@suse.cz

On Tue, Dec 11, 2018 at 06:21:40PM +0100, Jan Kara wrote:
> buffer_migrate_page() is the only caller of migrate_page_lock_buffers()
> move it close to it and also drop the now unused stub for !CONFIG_BLOCK.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

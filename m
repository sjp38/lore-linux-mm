Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEAB8E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 08:05:30 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so1119782ede.14
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 05:05:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si790695edn.1.2018.12.13.05.05.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 05:05:23 -0800 (PST)
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C063DAEBB
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 13:05:22 +0000 (UTC)
Date: Thu, 13 Dec 2018 13:05:20 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/6] mm: migration: Factor out code to compute expected
 number of page references
Message-ID: <20181213130520.GA28934@suse.de>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-2-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181211172143.7358-2-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mhocko@suse.cz

On Tue, Dec 11, 2018 at 06:21:38PM +0100, Jan Kara wrote:
> Factor out function to compute number of expected page references in
> migrate_page_move_mapping(). Note that we move hpage_nr_pages() and
> page_has_private() checks from under xas_lock_irq() however this is safe
> since we hold page lock.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 108908E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 09:19:31 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b7so1223196eda.10
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 06:19:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d1si928273edd.122.2018.12.13.06.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 06:19:29 -0800 (PST)
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6ACBAAEEA
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 14:19:29 +0000 (UTC)
Date: Thu, 13 Dec 2018 14:19:27 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/6] mm: migrate: Lock buffers before
 migrate_page_move_mapping()
Message-ID: <20181213141927.GB28934@suse.de>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-3-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181211172143.7358-3-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mhocko@suse.cz

On Tue, Dec 11, 2018 at 06:21:39PM +0100, Jan Kara wrote:
> Lock buffers before calling into migrate_page_move_mapping() so that
> that function doesn't have to know about buffers (which is somewhat
> unexpected anyway) and all the buffer head logic is in
> buffer_migrate_page().
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

This is a much nicer flow.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

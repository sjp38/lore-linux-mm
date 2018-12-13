Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38B998E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 10:35:47 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e17so1333651edr.7
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 07:35:47 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l16-v6si836911ejq.174.2018.12.13.07.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 07:35:46 -0800 (PST)
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C058FADD7
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 15:35:45 +0000 (UTC)
Date: Thu, 13 Dec 2018 15:35:43 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/6] mm: migrate: Drop unused argument of
 migrate_page_move_mapping()
Message-ID: <20181213153543.GF28934@suse.de>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-7-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181211172143.7358-7-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mhocko@suse.cz

On Tue, Dec 11, 2018 at 06:21:43PM +0100, Jan Kara wrote:
> All callers of migrate_page_move_mapping() now pass NULL for 'head'
> argument. Drop it.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 458FC8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:21:51 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f9so10254654pgs.13
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:21:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15si12024964pgl.141.2018.12.11.09.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 09:21:50 -0800 (PST)
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BD43CB005
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:21:48 +0000 (UTC)
From: Jan Kara <jack@suse.cz>
Subject: mm: migrate: Fix page migration stalls for blkdev pages
Date: Tue, 11 Dec 2018 18:21:37 +0100
Message-Id: <20181211172143.7358-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, mgorman@suse.de, Jan Kara <jack@suse.cz>

Hello,

this patch set deals with page migration stalls that were reported by our
customer due to block device page that had buffer head that was in bh LRU
cache.

The patch set modifies page migration code so that buffer heads are completely
handled inside buffer_migrate_page() and then provides new migration helper
for pages with buffer heads that is safe to use even for block device pages
and that also deals with bh lrus.

								Honza

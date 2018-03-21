Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1866B0022
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:44:44 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f59-v6so3933790plb.7
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:44:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1-v6si4662714pln.208.2018.03.21.15.44.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 15:44:43 -0700 (PDT)
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Subject: [PATCH 0/3] fs: Use memalloc_nofs_save/restore scope API
Date: Wed, 21 Mar 2018 17:44:26 -0500
Message-Id: <20180321224429.15860-1-rgoldwyn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, willy@infradead.org, david@fromorbit.com, Goldwyn Rodrigues <rgoldwyn@suse.de>

The goal of these patch set is to define the scope of the filesystems
code which should not be called back into in low memory allocations.
This primarily covers page writebacks, inode writebacks and writing
cache pages.

Eventually, once we are sure that FS code does not recurse in low memory
situations, we can use GFP_KERNEL instead of GFP_NOFS (without being
unsure of which flag to use ;)) However, that is a long way to go.

A previous discussion on this is listed here [1]

If you know of more situations, I would be glad to add.

[1] https://marc.info/?l=linux-fsdevel&m=152055278014609&w=2

-- 
Goldwyn

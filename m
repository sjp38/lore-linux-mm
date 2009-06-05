Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 469A76B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 19:38:48 -0400 (EDT)
Received: from relay1.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 3CF694844E
	for <linux-mm@kvack.org>; Sat,  6 Jun 2009 01:38:45 +0200 (CEST)
Date: Sat, 6 Jun 2009 01:38:44 +0200
From: Jan Kara <jack@suse.cz>
Subject: [Review request] Fix page_mkwrite() for blocksize < pagesize
Message-ID: <20090605233844.GA20220@duck.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  Hi,

  could someone have a look at a patch set I've posted a week or so ago
to LKML. It starts at:
http://lkml.org/lkml/2009/5/27/317
  Mainly, what I'd like to get opinions on is the third patch implementing
VFS helpers for easier handling of page_mkwrite() when blocksize <
pagesize. I'd like to get the patchset merged but before that I'd like to
get an agreement of people here that this is the way we want to go...
Thanks a lot for review in advance.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

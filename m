Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA23377
	for <linux-mm@kvack.org>; Sat, 20 Jun 1998 04:29:39 -0400
Subject: For the todo...
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 20 Jun 1998 02:29:04 -0500
Message-ID: <m1g1h0v8e7.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


In swap_state.c swapper_inode is bracketed in #ifdef SWAP_CACHE_INFO....

Eric

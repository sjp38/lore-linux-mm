Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0BCA96B0069
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 09:00:06 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id uy17so987118igb.3
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 06:00:05 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id nv8si4864662icc.75.2014.04.16.06.00.04
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 06:00:05 -0700 (PDT)
Date: Wed, 16 Apr 2014 09:00:02 -0400 (EDT)
Message-Id: <20140416.090002.2186526865564557549.davem@davemloft.net>
Subject: Re: [PATCH 10/19] NET: set PF_FSTRANS while holding sk_lock
From: David Miller <davem@davemloft.net>
In-Reply-To: <1397625226.4222.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040336.10604.96000.stgit@notabene.brown>
	<1397625226.4222.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: neilb@suse.de, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, netdev@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Apr 2014 22:13:46 -0700

> For applications handling millions of sockets, this makes a difference.

Indeed, this really is not acceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

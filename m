Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3214E6B0255
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 11:26:33 -0500 (EST)
Received: by pasz6 with SMTP id z6so209759370pas.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 08:26:32 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id hx5si23299922pbc.82.2015.11.09.08.26.32
        for <linux-mm@kvack.org>;
        Mon, 09 Nov 2015 08:26:32 -0800 (PST)
Date: Mon, 09 Nov 2015 11:26:29 -0500 (EST)
Message-Id: <20151109.112629.1860510744923009883.davem@davemloft.net>
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional
 kfree()/vfree()
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151109121126.GD11149@quack.suse.cz>
References: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20151109121126.GD11149@quack.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jack@suse.cz
Cc: penguin-kernel@I-love.SAKURA.ne.jp, akpm@linux-foundation.org, linux-mm@kvack.org, linux@arm.linux.org.uk, linux-acpi@vger.kernel.org, drbd-user@lists.linbit.com, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, oleg.drokin@intel.com, andreas.dilger@intel.com, codalist@coda.cs.cmu.edu, linux-mtd@lists.infradead.org, jack@suse.com, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org

From: Jan Kara <jack@suse.cz>
Date: Mon, 9 Nov 2015 13:11:26 +0100

> You can add
> 
> Acked-by: Jan Kara <jack@suse.com>
> 
> for the UDF and fs/xattr.c parts.

Please do not quote and entire large patch just to give an ACK.

Just quote the minimum necessary context, which is usually just
the commit message.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC9A900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 14:47:21 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so1280911pdj.29
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 11:47:21 -0700 (PDT)
Received: from mail.tuxags.com (hydra.tuxags.com. [64.13.172.54])
        by mx.google.com with ESMTP id i7si2137937pdo.22.2014.10.28.11.47.19
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 11:47:20 -0700 (PDT)
Date: Tue, 28 Oct 2014 11:47:19 -0700
From: Matt Mullins <mmullins@mmlx.us>
Subject: Re: [PATCH v3 1/4] mm/balloon_compaction: redesign ballooned pages
 management
Message-ID: <20141028184719.GB29098@hydra.tuxags.com>
References: <20140927183403.13738.22121.stgit@zurg>
 <20140927191515.13738.18027.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140927191515.13738.18027.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Rafael Aquini <aquini@redhat.com>, Stable <stable@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>

On Sat, Sep 27, 2014 at 11:15:16PM +0400, Konstantin Khlebnikov wrote:
> This patch fixes all of them.

It seems to have rendered virtio_balloon completely ineffective without
CONFIG_COMPACTION and CONFIG_BALLOON_COMPACTION, even for the case that I'm
expanding the memory available to my VM.

Was this intended?  Should Kconfig be updated so that VIRTIO_BALLOON depends on
BALLOON_COMPACTION now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

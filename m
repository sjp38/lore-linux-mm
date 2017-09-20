Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68CDA6B02BF
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:56:49 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m103so6342309iod.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:56:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f198si99761ita.170.2017.09.20.13.56.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 13:56:44 -0700 (PDT)
Date: Wed, 20 Sep 2017 13:56:42 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 14/31] vxfs: Define usercopy region in vxfs_inode slab
 cache
Message-ID: <20170920205642.GA20023@infradead.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
 <1505940337-79069-15-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505940337-79069-15-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Hi Kees,

I've only got this single email from you, which on it's own doesn't
compile and seems to be part of a 31 patch series.

So as-is NAK, doesn't work.

Please make sure to always send every patch in a series to every
developer you want to include.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

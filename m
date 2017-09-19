Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 225AA6B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 10:25:05 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b9so3996117wra.3
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 07:25:05 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b5si1380048wmg.254.2017.09.19.07.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Sep 2017 07:25:04 -0700 (PDT)
Date: Tue, 19 Sep 2017 16:25:03 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 2/4] bdi: introduce BDI_CAP_SYNCHRONOUS_IO
Message-ID: <20170919142503.GA20306@lst.de>
References: <1505805001-30187-1-git-send-email-minchan@kernel.org> <1505805001-30187-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505805001-30187-3-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team <kernel-team@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

I'm only seeing patch 2 of 4 - please resend the whole series so
that it can properly be reviewed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

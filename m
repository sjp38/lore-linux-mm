Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF9BA6B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 01:41:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 188so3546284pgb.3
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 22:41:22 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id e22si777201plj.455.2017.09.19.22.41.20
        for <linux-mm@kvack.org>;
        Tue, 19 Sep 2017 22:41:21 -0700 (PDT)
Date: Wed, 20 Sep 2017 14:41:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 2/4] bdi: introduce BDI_CAP_SYNCHRONOUS_IO
Message-ID: <20170920054118.GA9428@bbox>
References: <1505805001-30187-1-git-send-email-minchan@kernel.org>
 <1505805001-30187-3-git-send-email-minchan@kernel.org>
 <20170919142503.GA20306@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170919142503.GA20306@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team <kernel-team@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Sep 19, 2017 at 04:25:03PM +0200, Christoph Hellwig wrote:
> I'm only seeing patch 2 of 4 - please resend the whole series so
> that it can properly be reviewed.

Yub, I will resend.
Thanks for the review in advance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

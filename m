Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 671FD6B0099
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 07:10:39 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so23513qgd.23
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 04:10:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id s6si594940qas.242.2014.04.02.04.10.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Apr 2014 04:10:36 -0700 (PDT)
Date: Wed, 2 Apr 2014 04:10:32 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
Message-ID: <20140402111032.GA27551@infradead.org>
References: <533B04A9.6090405@bbn.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <533B04A9.6090405@bbn.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Hansen <rhansen@bbn.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Greg Troxel <gdt@ir.bbn.com>

On Tue, Apr 01, 2014 at 02:25:45PM -0400, Richard Hansen wrote:
> For the flags parameter, POSIX says "Either MS_ASYNC or MS_SYNC shall
> be specified, but not both." [1]  There was already a test for the
> "both" condition.  Add a test to ensure that the caller specified one
> of the flags; fail with EINVAL if neither are specified.

This breaks various (sloppy) existing userspace for no gain.

NAK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

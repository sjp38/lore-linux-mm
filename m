Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id A26406B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 06:05:55 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id mc17so1172034pbc.21
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 03:05:55 -0700 (PDT)
Received: from psmtp.com ([74.125.245.181])
        by mx.google.com with SMTP id cj2si17393429pbc.357.2013.10.30.03.05.53
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 03:05:54 -0700 (PDT)
Date: Wed, 30 Oct 2013 19:06:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 13/15] slab: use struct page for slab management
Message-ID: <20131030100614.GB5753@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1381913052-23875-14-git-send-email-iamjoonsoo.kim@lge.com>
 <20131030082800.GA5753@lge.com>
 <5270C666.6090209@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5270C666.6090209@iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, Oct 30, 2013 at 10:42:14AM +0200, Pekka Enberg wrote:
> On 10/30/2013 10:28 AM, Joonsoo Kim wrote:
> >If you want an incremental patch against original patchset,
> >I can do it. Please let me know what you want.
> 
> Yes, please. Incremental is much easier to deal with if we want this
> to end up in v3.13.

Okay. I just sent them.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

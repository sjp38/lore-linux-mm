Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C480E831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 16:41:36 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id o65so57299958oif.15
        for <linux-mm@kvack.org>; Thu, 18 May 2017 13:41:36 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c125si175620oia.89.2017.05.18.13.41.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 13:41:35 -0700 (PDT)
Date: Thu, 18 May 2017 23:35:51 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 0/3] KSMscale cleanup/optimizations
Message-ID: <20170518203550.hwtsugoifjqizyoi@mwanda>
References: <20170518173721.22316-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518173721.22316-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Evgheni Dereveanchin <ederevea@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Arjan van de Ven <arjan@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Gavin Guo <gavin.guo@canonical.com>, Jay Vosburgh <jay.vosburgh@canonical.com>, Mel Gorman <mgorman@techsingularity.net>

On Thu, May 18, 2017 at 07:37:18PM +0200, Andrea Arcangeli wrote:
> 2/3 should fix the false positive from Dan's static checker. Dan could
> you check if it still complains?

That works.  Thanks!

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

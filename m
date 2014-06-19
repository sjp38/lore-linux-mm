Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4E97A6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 03:14:16 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id l4so1198665lbv.28
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 00:14:15 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id w8si3496945lal.26.2014.06.19.00.14.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jun 2014 00:14:14 -0700 (PDT)
Date: Thu, 19 Jun 2014 11:14:04 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH] fork: dup_mm: init vm stat counters under mmap_sem
Message-ID: <20140619071404.GA20390@esperanza>
References: <1403098391-24546-1-git-send-email-vdavydov@parallels.com>
 <20140618152209.GA14818@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140618152209.GA14818@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 18, 2014 at 05:22:09PM +0200, Oleg Nesterov wrote:
> But perhaps this deserves more cleanups, with or without this patch
> the initialization does not look consistent. dup_mmap() nullifies
> locked_vm/pinned_vm/mmap/map_count while mm_init() clears core_state/
> nr_ptes/rss_stat.

Agree. Will try to clean this up.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

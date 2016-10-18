Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 682A8280251
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:40:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u84so222142857pfj.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 03:40:22 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id x3si27506545paw.155.2016.10.18.03.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 03:40:21 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id r16so14830220pfg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 03:40:21 -0700 (PDT)
Date: Tue, 18 Oct 2016 21:40:11 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC] reduce latency in __purge_vmap_area_lazy
Message-ID: <20161018214011.02b0deab@roar.ozlabs.ibm.com>
In-Reply-To: <1476773771-11470-1-git-send-email-hch@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@linux-foundation.org, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 18 Oct 2016 08:56:05 +0200
Christoph Hellwig <hch@lst.de> wrote:

> Hi all,
> 
> this is my spin at sorting out the long lock hold times in
> __purge_vmap_area_lazy.  It is based on the patch from Joel sent this
> week.  I don't have any good numbers for it, but it survived an
> xfstests run on XFS which is a significant vmalloc user.  The
> changelogs could still be improved as well, but I'd rather get it
> out quickly for feedback and testing.

All seems pretty good to me.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

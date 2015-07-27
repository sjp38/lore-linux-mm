Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB8A6B0038
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 06:59:59 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so110900959wib.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 03:59:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fz6si13298978wic.116.2015.07.27.03.59.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 03:59:57 -0700 (PDT)
Date: Mon, 27 Jul 2015 11:59:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] bootmem: avoid freeing to bootmem after bootmem is done
Message-ID: <20150727105951.GO2561@suse.de>
References: <1437771226-31255-1-git-send-email-cmetcalf@ezchip.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1437771226-31255-1-git-send-email-cmetcalf@ezchip.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@ezchip.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Paul McQuade <paulmcquad@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 24, 2015 at 04:53:46PM -0400, Chris Metcalf wrote:
> Bootmem isn't popular any more, but some architectures still use
> it, and freeing to bootmem after calling free_all_bootmem_core()
> can end up scribbling over random memory.  Instead, make sure the
> kernel panics by ensuring the node_bootmem_map field is non-NULL
> when are freeing or marking bootmem.
> 
> An instance of this bug was just fixed in the tile architecture
> ("tile: use free_bootmem_late() for initrd") and catching this case
> more widely seems like a good thing.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>

In general it looks fine  but you could just WARN_ON, return and still
boot the kernel too. Obviously it would need to be fixed but Linus will
push back if he spots a BUG_ON when there was a recovery option.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

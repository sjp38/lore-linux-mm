Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2DB6B0254
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 12:05:31 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so145571871wic.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 09:05:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xy9si31448735wjc.160.2015.07.27.09.05.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 09:05:29 -0700 (PDT)
Date: Mon, 27 Jul 2015 17:05:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] bootmem: avoid freeing to bootmem after bootmem is
 done
Message-ID: <20150727160525.GQ2561@suse.de>
References: <20150727105951.GO2561@suse.de>
 <1438011366-11474-1-git-send-email-cmetcalf@ezchip.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1438011366-11474-1-git-send-email-cmetcalf@ezchip.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@ezchip.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Paul McQuade <paulmcquad@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 27, 2015 at 11:36:06AM -0400, Chris Metcalf wrote:
> Bootmem isn't popular any more, but some architectures still use it,
> and freeing to bootmem after calling free_all_bootmem_core() can end
> up scribbling over random memory.  Instead, make sure the kernel
> generates a warning in this case by ensuring the node_bootmem_map
> field is non-NULL when are freeing or marking bootmem.
> 
> An instance of this bug was just fixed in the tile architecture
> ("tile: use free_bootmem_late() for initrd") and catching this case
> more widely seems like a good thing.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

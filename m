Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 989FE280290
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 05:58:23 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r68so24093174wmd.0
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 02:58:23 -0800 (PST)
Received: from sym2.noone.org (sym2.noone.org. [178.63.92.236])
        by mx.google.com with ESMTPS id fk2si9683389wjb.20.2016.11.11.02.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 02:58:22 -0800 (PST)
Date: Fri, 11 Nov 2016 11:58:19 +0100
From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [mm PATCH v3 12/23] arch/nios2: Add option to skip DMA sync as a
 part of map and unmap
Message-ID: <20161111105818.GB9338@distanz.ch>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
 <20161110113518.76501.52225.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161110113518.76501.52225.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Ley Foon Tan <lftan@altera.com>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On 2016-11-10 at 12:35:18 +0100, Alexander Duyck <alexander.h.duyck@intel.com> wrote:
> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> via a sync_for_cpu or sync_for_device call.
> 
> Cc: Ley Foon Tan <lftan@altera.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

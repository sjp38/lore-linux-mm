Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5206B0261
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:24:29 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id m60so43041261uam.3
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:24:29 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id x38si958487uax.120.2016.08.05.07.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 07:20:05 -0700 (PDT)
Date: Fri, 5 Aug 2016 09:17:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm/slab: Improve performance of gathering slabinfo
 stats
In-Reply-To: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com>
Message-ID: <alpine.DEB.2.20.1608050917130.27772@east.gentwo.org>
References: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 4 Aug 2016, Aruna Ramakrishna wrote:

> On large systems, when some slab caches grow to millions of objects (and
> many gigabytes), running 'cat /proc/slabinfo' can take up to 1-2 seconds.
> During this time, interrupts are disabled while walking the slab lists
> (slabs_full, slabs_partial, and slabs_free) for each node, and this
> sometimes causes timeouts in other drivers (for instance, Infiniband).

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A21A76B0253
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:09:20 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so18443391pdj.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:09:20 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id tx6si23117880pab.40.2015.07.24.13.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 13:09:19 -0700 (PDT)
Received: by pdjr16 with SMTP id r16so18443281pdj.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:09:19 -0700 (PDT)
Date: Fri, 24 Jul 2015 13:09:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v2 2/4] mm: unify checks in alloc_pages_node family of
 functions
In-Reply-To: <1437749126-25867-2-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1507241309060.5215@chino.kir.corp.google.com>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz> <1437749126-25867-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, 24 Jul 2015, Vlastimil Babka wrote:

> Perform the same debug checks in alloc_pages_node() as are done in
> alloc_pages_exact_node() and __alloc_pages_node() by making the latter
> function the inner core of the former ones.
> 
> Change the !node_online(nid) check from VM_BUG_ON to VM_WARN_ON since it's not
> fatal and this patch may expose some buggy callers.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

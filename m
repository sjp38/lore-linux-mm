Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 251CA6B0009
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 17:41:44 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id w128so76235165pfb.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 14:41:44 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id x80si7371040pfi.97.2016.03.01.14.41.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 14:41:43 -0800 (PST)
Received: by mail-pa0-x229.google.com with SMTP id fl4so119997752pad.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 14:41:43 -0800 (PST)
Date: Tue, 1 Mar 2016 14:41:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH mmotm] mm, sl[au]b: print gfp_flags as strings in
 slab_out_of_memory()
In-Reply-To: <1456859312-26207-1-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1603011439390.24913@chino.kir.corp.google.com>
References: <1456859312-26207-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, 1 Mar 2016, Vlastimil Babka wrote:

> We can now print gfp_flags more human-readable. Make use of this in
> slab_out_of_memory() for SLUB and SLAB. Also convert the SLAB variant it to
> pr_warn() along the way.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

Although I've always been curious about the usefulness of these out of 
memory calls in the first place.  They are obviously for debugging, but 
have they actually helped to diagnose anything?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94E6B6B025E
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 18:17:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 144so60658702pfv.5
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 15:17:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p62si39003794pfi.27.2016.11.08.15.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 15:17:28 -0800 (PST)
Date: Tue, 8 Nov 2016 15:17:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, slab: faster active and free stats
Message-Id: <20161108151727.b64035da825c69bced88b46d@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1611081505240.13403@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1611081505240.13403@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Greg Thelen <gthelen@google.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 8 Nov 2016 15:06:45 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> Reading /proc/slabinfo or monitoring slabtop(1) can become very expensive
> if there are many slab caches and if there are very lengthy per-node
> partial and/or free lists.
> 
> Commit 07a63c41fa1f ("mm/slab: improve performance of gathering slabinfo
> stats") addressed the per-node full lists which showed a significant
> improvement when no objects were freed.  This patch has the same
> motivation and optimizes the remainder of the usecases where there are
> very lengthy partial and free lists.
> 
> This patch maintains per-node active_slabs (full and partial) and
> free_slabs rather than iterating the lists at runtime when reading
> /proc/slabinfo.

Are there any nice numbers you can share?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

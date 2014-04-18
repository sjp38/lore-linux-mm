Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id D69E76B0038
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:13:03 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so1822443eek.16
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:13:03 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 49si41362528een.125.2014.04.18.11.13.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 11:13:02 -0700 (PDT)
Date: Fri, 18 Apr 2014 14:13:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 12/16] mm: shmem: Avoid atomic operation during
 shmem_getpage_gfp
Message-ID: <20140418181300.GG29210@cmpxchg.org>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
 <1397832643-14275-13-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397832643-14275-13-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Apr 18, 2014 at 03:50:39PM +0100, Mel Gorman wrote:
> shmem_getpage_gfp uses an atomic operation to set the SwapBacked field
> before it's even added to the LRU or visible. This is unnecessary as what
> could it possible race against?  Use an unlocked variant.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

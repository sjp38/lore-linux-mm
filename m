Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id DFD076B0037
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:08:40 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so1847899eek.29
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:08:40 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 43si41331110eei.145.2014.04.18.11.08.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 11:08:39 -0700 (PDT)
Date: Fri, 18 Apr 2014 14:08:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/16] mm: page_alloc: Only check the alloc flags and
 gfp_mask for dirty once
Message-ID: <20140418180836.GE29210@cmpxchg.org>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
 <1397832643-14275-9-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397832643-14275-9-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Apr 18, 2014 at 03:50:35PM +0100, Mel Gorman wrote:
> Currently it's calculated once per zone in the zonelist.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

I would have assumed the compiler can detect such a loop invariant...
Alas,

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

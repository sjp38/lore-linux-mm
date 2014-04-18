Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id B72076B0035
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 13:53:00 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so1797749eek.18
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:53:00 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id y6si41291070eep.107.2014.04.18.10.52.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 10:52:59 -0700 (PDT)
Date: Fri, 18 Apr 2014 13:52:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 04/16] mm: page_alloc: Do not treat a zone that cannot be
 used for dirty pages as "full"
Message-ID: <20140418175256.GB29210@cmpxchg.org>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
 <1397832643-14275-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397832643-14275-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Apr 18, 2014 at 03:50:31PM +0100, Mel Gorman wrote:
> If a zone cannot be used for a dirty page then it gets marked "full"
> which is cached in the zlc and later potentially skipped by allocation
> requests that have nothing to do with dirty zones.

Urgh.  Thanks for the fix.

> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

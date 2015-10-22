Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id AA1C86B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 18:36:03 -0400 (EDT)
Received: by lfbn126 with SMTP id n126so30303217lfb.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 15:36:02 -0700 (PDT)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id sz4si10915080lbb.42.2015.10.22.15.36.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 15:36:02 -0700 (PDT)
Received: by lfbn126 with SMTP id n126so30302877lfb.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 15:36:01 -0700 (PDT)
Date: Fri, 23 Oct 2015 01:35:59 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 10/12] mm: page migration use migration entry for
 swapcache too
Message-ID: <20151022223558.GT2080@uranus>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182203200.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510182203200.2481@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org

On Sun, Oct 18, 2015 at 10:05:28PM -0700, Hugh Dickins wrote:
> Hitherto page migration has avoided using a migration entry for a
> swapcache page mapped into userspace, apparently for historical reasons.
> So any page blessed with swapcache would entail a minor fault when it's
> next touched, which page migration otherwise tries to avoid.  Swapcache
> in an mlocked area is rare, so won't often matter, but still better fixed.
> 
> Just rearrange the block in try_to_unmap_one(), to handle TTU_MIGRATION
> before checking PageAnon, that's all (apart from some reindenting).
> 
> Well, no, that's not quite all: doesn't this by the way fix a soft_dirty
> bug, that page migration of a file page was forgetting to transfer the
> soft_dirty bit?  Probably not a serious bug: if I understand correctly,
> soft_dirty afficionados usually have to handle file pages separately
> anyway; but we publish the bit in /proc/<pid>/pagemap on file mappings
> as well as anonymous, so page migration ought not to perturb it.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Sorry for delay in response. Indeed this should fix the nit, thanks!
Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5B66B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 06:11:14 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so2998535eek.6
        for <linux-mm@kvack.org>; Fri, 02 May 2014 03:11:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f45si1161411eet.309.2014.05.02.03.11.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 03:11:13 -0700 (PDT)
Date: Fri, 2 May 2014 11:11:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch v2 2/4] mm, compaction: return failed migration target
 pages back to freelist
Message-ID: <20140502101109.GP23991@suse.de>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405011434420.23898@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1405011434420.23898@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 01, 2014 at 02:35:42PM -0700, David Rientjes wrote:
> Memory compaction works by having a "freeing scanner" scan from one end of a 
> zone which isolates pages as migration targets while another "migrating scanner" 
> scans from the other end of the same zone which isolates pages for migration.
> 
> When page migration fails for an isolated page, the target page is returned to 
> the system rather than the freelist built by the freeing scanner.  This may 
> require the freeing scanner to continue scanning memory after suitable migration 
> targets have already been returned to the system needlessly.
> 
> This patch returns destination pages to the freeing scanner freelist when page 
> migration fails.  This prevents unnecessary work done by the freeing scanner but 
> also encourages memory to be as compacted as possible at the end of the zone.
> 
> Reported-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

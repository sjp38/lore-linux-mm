Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0EF6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:23:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p43so24148328wrb.6
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:23:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e6si16374109wrc.122.2017.07.25.08.23.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 08:23:02 -0700 (PDT)
Date: Tue, 25 Jul 2017 17:23:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725152300.GM26723@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725142626.GJ26723@dhcp22.suse.cz>
 <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 25-07-17 18:17:54, Kirill A. Shutemov wrote:
> > before the patch
> > min: 306300.00 max: 6731916.00 avg: 437962.07 std: 92898.30 nr: 100000
> > 
> > after
> > min: 303196.00 max: 5728080.00 avg: 436081.87 std: 96165.98 nr: 100000
> > 
> > The results are well withing noise as I would expect.
> 
> I've silightly modified your test case: replaced cpuid + rdtsc with
> rdtscp. cpuid overhead is measurable in such tight loop.
> 
> 3 runs before the patch:
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>  177200  205000  212900  217800  223700 2377000
>  172400  201700  209700  214300  220600 1343000
>  175700  203800  212300  217100  223000 1061000
> 
> 3 runs after the patch:
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>  175900  204800  213000  216400  223600 1989000
>  180300  210900  219600  223600  230200 3184000
>  182100  212500  222000  226200  232700 1473000
> 
> The difference is still measuarble. Around 3%.

what is stdev?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

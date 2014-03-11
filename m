Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5676B00A8
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 12:28:50 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id l18so5926498wgh.31
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 09:28:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cs8si1887018wib.70.2014.03.11.09.28.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 09:28:48 -0700 (PDT)
Date: Tue, 11 Mar 2014 16:28:45 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -mm] mm,numa,mprotect: always continue after finding a
 stable thp page
Message-ID: <20140311162845.GA30604@suse.de>
References: <5318E4BC.50301@oracle.com>
 <20140306173137.6a23a0b2@cuia.bos.redhat.com>
 <5318FC3F.4080204@redhat.com>
 <20140307140650.GA1931@suse.de>
 <20140307150923.GB1931@suse.de>
 <20140307182745.GD1931@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140307182745.GD1931@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com

On Fri, Mar 07, 2014 at 06:27:45PM +0000, Mel Gorman wrote:
> > This is a completely untested prototype. It rechecks pmd_trans_huge
> > under the lock and falls through if it hit a parallel split. It's not
> > perfect because it could decide to fall through just because there was
> > no prot_numa work to do but it's for illustration purposes. Secondly,
> > I noted that you are calling invalidate for every pmd range. Is that not
> > a lot of invalidations? We could do the same by just tracking the address
> > of the first invalidation.
> > 
> 
> And there were other minor issues. This is still untested but Sasha,
> can you try it out please? I discussed this with Rik on IRC for a bit and
> reckon this should be sufficient if the correct race has been identified.
> 

Any luck with this patch Sasha? It passed basic tests here but I had not
seen the issue trigger either.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

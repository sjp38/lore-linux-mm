Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id CB0766B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 15:39:12 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so528865dak.0
        for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:39:12 -0800 (PST)
Date: Fri, 22 Feb 2013 12:38:26 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/7] ksm: responses to NUMA review
In-Reply-To: <5126E987.7020809@gmail.com>
Message-ID: <alpine.LNX.2.00.1302221227530.6100@eggly.anvils>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <5126E987.7020809@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 22 Feb 2013, Ric Mason wrote:
> On 02/21/2013 04:17 PM, Hugh Dickins wrote:
> > Here's a second KSM series, based on mmotm 2013-02-19-17-20: partly in
> > response to Mel's review feedback, partly fixes to issues that I found
> > myself in doing more review and testing.  None of the issues fixed are
> > truly show-stoppers, though I would prefer them fixed sooner than later.
> 
> Do you have any ideas ksm support page cache and tmpfs?

No.  It's only been asked as a hypothetical question: I don't know of
anyone actually needing it, and I wouldn't have time to do it myself.

It would be significantly more invasive than just dealing with anonymous
memory: with anon, we already have the infrastructure for read-only pages,
but we don't at present have any notion of read-only pagecache.

Just doing it in tmpfs?  Well, yes, that might be easier: since v3.1's
radix_tree rework, shmem/tmpfs mostly goes through its own interfaces
to pagecache, so read-only pagecache, and hence KSM, might be easier
to implement there than more generally.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

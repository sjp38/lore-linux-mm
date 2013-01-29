Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 154406B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 20:38:41 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id bi5so48335pad.27
        for <linux-mm@kvack.org>; Mon, 28 Jan 2013 17:38:40 -0800 (PST)
Date: Mon, 28 Jan 2013 17:38:43 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/11] ksm: allow trees per NUMA node
In-Reply-To: <20130128150854.6813b1ca.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1301281717320.4947@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251753380.29196@eggly.anvils> <20130128150854.6813b1ca.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 Jan 2013, Andrew Morton wrote:
> On Fri, 25 Jan 2013 17:54:53 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > +/* Zeroed when merging across nodes is not allowed */
> > +static unsigned int ksm_merge_across_nodes = 1;
> 
> I spose this should be __read_mostly.  If __read_mostly is not really a
> synonym for __make_write_often_storage_slower.  I continue to harbor
> fear, uncertainty and doubt about this...

Could do.  No strong feeling, but I think I'd rather it share its
cacheline with other KSM-related stuff, than be off mixed up with
unrelateds.  I think there's a much stronger case for __read_mostly
when it's a library thing accessed by different subsystems.

You're right that this variable is accessed significantly more often
that the other KSM tunables, so deserves a __read_mostly more than
they do.  But where to stop?  Similar reluctance led me to avoid
using "unlikely" throughout ksm.c, unlikely as some conditions are
(I'm aghast to see that Andrea sneaked in a "likely" :).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

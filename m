Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 2FE0E6B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 20:07:18 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so1805513pbc.25
        for <linux-mm@kvack.org>; Mon, 28 Jan 2013 17:07:17 -0800 (PST)
Date: Mon, 28 Jan 2013 17:07:15 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/11] ksm: NUMA trees and page migration
In-Reply-To: <20130128155452.16882a6e.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1301281701010.4947@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <20130128155452.16882a6e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

On Mon, 28 Jan 2013, Andrew Morton wrote:
> On Fri, 25 Jan 2013 17:53:10 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > Here's a KSM series
> 
> Sanity check: do you have a feeling for how useful KSM is? 
> Performance/space improvements for typical (or atypical) workloads? 
> Are people using it?  Successfully?
> 
> IOW, is it justifying itself?

I have no idea!  To me it's simply a technical challenge - and I agree
with your implication that that's not a good enough justification.

I've added Marcelo and Gleb and the KVM list to the Cc:
my understanding is that it's the KVM guys who really appreciate KSM.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 8D59B6B0030
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 05:45:17 -0500 (EST)
Date: Tue, 29 Jan 2013 12:45:14 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 0/11] ksm: NUMA trees and page migration
Message-ID: <20130129104513.GA15004@redhat.com>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
 <20130128155452.16882a6e.akpm@linux-foundation.org>
 <alpine.LNX.2.00.1301281701010.4947@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1301281701010.4947@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

On Mon, Jan 28, 2013 at 05:07:15PM -0800, Hugh Dickins wrote:
> On Mon, 28 Jan 2013, Andrew Morton wrote:
> > On Fri, 25 Jan 2013 17:53:10 -0800 (PST)
> > Hugh Dickins <hughd@google.com> wrote:
> > 
> > > Here's a KSM series
> > 
> > Sanity check: do you have a feeling for how useful KSM is? 
> > Performance/space improvements for typical (or atypical) workloads? 
> > Are people using it?  Successfully?
> > 
> > IOW, is it justifying itself?
> 
> I have no idea!  To me it's simply a technical challenge - and I agree
> with your implication that that's not a good enough justification.
> 
> I've added Marcelo and Gleb and the KVM list to the Cc:
> my understanding is that it's the KVM guys who really appreciate KSM.
> 
KSM is used on all RH kvm deployments for memory overcommit. I asked
around for numbers and got the answer that it allows to squeeze anywhere
between 10% and 100% more VMs on the same machine depends on a type of
a guest OS and how similar workloads of VMs are. And management tries
to keep VMs with similar OSes/workloads on the same host to gain more
from KSM.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

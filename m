Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A93786B0071
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 13:03:01 -0400 (EDT)
Date: Tue, 3 Jul 2012 19:02:58 +0200
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: [PATCH v2] KSM: numa awareness sysfs knob
Message-ID: <20120703170257.GC3964@dhcp-27-244.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1207021425110.24806@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Mon, 2 Jul 2012, David Rientjes wrote:

> > The problem of the first patch/RFC was that merging algorithm was unstable
> > and could merge pages with distance higher than was set up (described by 
> > Nai Xia in RFC thread [1]). Sure, this instability could be solved, but for
> > ksm pages shared by many other pages on different nodes we would have to
> > still
> > recalculate which page is "in the middle" and in case of change migrate it 
> > between nodes every time when ksmd reach new shareable page or when some 
> > sharing page is removed.
> > 
> 
> Or you could simply refuse to ever merge any page that is identical to a 
> page on a node with a distance greater than the threshold, i.e. never 
> merge pages even under the threshold if a page exists on a node higher 
> than the threshold.

Position of the shared page would be really dependent on order of scanning.
We could have shared page in the ideal middle as well as on the edge where it
would block merging of other pages even under the threshold. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

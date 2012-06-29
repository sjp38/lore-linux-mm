Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 2FB1D6B0068
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:05:22 -0400 (EDT)
Date: Fri, 29 Jun 2012 18:05:10 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] KSM: numa awareness sysfs knob
Message-ID: <20120629160510.GA10082@cmpxchg.org>
References: <1340970592-25001-1-git-send-email-pholasek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340970592-25001-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Fri, Jun 29, 2012 at 01:49:52PM +0200, Petr Holasek wrote:
> Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_nodes
> which control merging pages across different numa nodes.
> When it is set to zero only pages from the same node are merged,
> otherwise pages from all nodes can be merged together (default behavior).

Is it conceivable that admins may (in the future) want to merge only
across nodes that are below a given distance threshold?

I'm not asking to implement this, just whether the knob can be
introduced such that it's future-compatible.  Make it default to a
Very High Number and only allow setting it to 0 for now e.g.?  And
name it max_node_merge_distance (I'm bad at names)?

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

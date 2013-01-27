Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id D218F6B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 16:55:24 -0500 (EST)
Received: by mail-da0-f48.google.com with SMTP id k18so944432dae.21
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 13:55:24 -0800 (PST)
Date: Sun, 27 Jan 2013 13:55:19 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/11] ksm: allow trees per NUMA node
In-Reply-To: <1359256581.4159.16.camel@kernel>
Message-ID: <alpine.LNX.2.00.1301271352520.17144@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251753380.29196@eggly.anvils> <1359249282.4159.4.camel@kernel> <alpine.LNX.2.00.1301261826000.7411@eggly.anvils> <1359256581.4159.16.camel@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 26 Jan 2013, Simon Jeons wrote:
> On Sat, 2013-01-26 at 18:54 -0800, Hugh Dickins wrote:
> > 
> > So you'd like us to add code for moving a node from one tree to another
> > in ksm_migrate_page() (and what would it do when it collides with an
> 
> Without numa awareness, I still can't understand your explanation why
> can't insert the node to the tree just after page migration instead of
> inserting it at the next scan.

The node is already there in the right (only) tree in that case.

> 
> > existing node?), code which will then be removed a few patches later
> > when ksm page migration is fully enabled?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

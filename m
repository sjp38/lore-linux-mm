Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 0674D6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 10:31:25 -0400 (EDT)
Date: Fri, 20 Apr 2012 09:07:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH, RFC 0/3] Introduce new O_HOT and O_COLD flags
In-Reply-To: <alpine.LFD.2.00.1204201313231.27750@dhcp-27-109.brq.redhat.com>
Message-ID: <alpine.DEB.2.00.1204200904080.32338@router.home>
References: <1334863211-19504-1-git-send-email-tytso@mit.edu>  <4F912880.70708@panasas.com>  <alpine.LFD.2.00.1204201120060.27750@dhcp-27-109.brq.redhat.com> <1334919662.5879.23.camel@dabdike>
 <alpine.LFD.2.00.1204201313231.27750@dhcp-27-109.brq.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Boaz Harrosh <bharrosh@panasas.com>, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-mm@kvack.org

> > I cc'd linux-mm to see if there might be an interest in this ... or even
> > if it's worth it: I can also see we don't necessarily want userspace to
> > be able to tamper with our idea of what's hot and cold in the page
> > cache, since we get it primarily from the lru lists.
> >
> > James

The notion of hor and cold in the page allocator refers to processor cache
hotness and is used for pages on the per cpu free lists.

F.e. cold pages are used when I/O is soon expected to occur on them
because we want to avoid having to evict cache lines. Cold pages have been
freed a long time ago.

Hot pages are those that have been recently freed (we know that some
cachelines are present therefore) and thus it is likely that acquisition
by another process will allow that process to reuse the cacheline already
present avoiding a trip to memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

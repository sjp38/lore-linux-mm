Date: Mon, 17 Sep 2007 11:42:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 8/14] Reclaim Scalability:  Ram Disk Pages are
 non-reclaimable
In-Reply-To: <1190040039.5460.45.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709171142360.27057@schroedinger.engr.sgi.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
 <20070914205451.6536.39585.sendpatchset@localhost>  <46EDDF0F.2080800@redhat.com>
 <1190040039.5460.45.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007, Lee Schermerhorn wrote:

> So, I think I should just mark ramfs address space as nonreclaimable,
> similar to ram disk.  Do you agree?

Ack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

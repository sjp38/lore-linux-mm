From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200102270547.VAA94414@google.engr.sgi.com>
Subject: Re: 2.5 page cache improvement idea
Date: Mon, 26 Feb 2001 21:47:25 -0800 (PST)
In-Reply-To: <200102270326.f1R3QII16835@eng1.sequent.com> from "Gerrit Huizenga" at Feb 26, 2001 07:26:18 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gerrit@us.ibm.com
Cc: Ben LaHaise <bcrl@redhat.com>, Chuck Lever <Charles.Lever@netapp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> node traffic is relatively expensive.  As a result, wasting a small
> number of physical pages on duplicate read-only pages cuts down node
> to node traffic in most cases.  Many NUMA systems have a cache for
> remote memory (some cache only remote pages, some cache local and remote
> pages in the same cache - icky but cheaper).  As that cache cycles,
> it is cheaper to replace read-only text pages from the local node
> rather than the remote.  So, for things like kernel text (e.g. one of
> the SGI patches) and for glibc's text, as well as the text of other

The mips64 port onto SGI o2000 uses kernel text replication, that has 
been part of 2.3/2.4 for a long time now. Is there another patch you
are talking about here?

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

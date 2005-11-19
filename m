Date: Sat, 19 Nov 2005 18:30:01 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: why its dead now?
In-Reply-To: <20051115142702.GC31096@sirius.cs.amherst.edu>
Message-ID: <Pine.LNX.4.63.0511191829100.13937@cuia.boston.redhat.com>
References: <f68e01850511131035l3f0530aft6076f156d4f62171@mail.gmail.com>
 <20051115142702.GC31096@sirius.cs.amherst.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Scott F. H. Kaplan" <sfkaplan@cs.amherst.edu>
Cc: Nitin Gupta <nitingupta.mail@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Nov 2005, Scott F. H. Kaplan wrote:

> For completely different purposes, we have a 2.4.x kernel that
> maintains this history efficiently.  If you (or anyone else) are
> interested at some point in porting this reference-pattern-gathering
> code forward to the 2.6.x line,

Marcelo already did some work on that:

	http://linux-mm.org/PageTrace

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

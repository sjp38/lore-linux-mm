Date: Mon, 5 Mar 2007 10:17:06 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
In-Reply-To: <20070305171224.GB2909@infradead.org>
Message-ID: <Pine.LNX.4.64.0703051015430.6620@schroedinger.engr.sgi.com>
References: <20070305161746.GD8128@wotan.suse.de> <20070305171224.GB2909@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 5 Mar 2007, Christoph Hellwig wrote:

> Now that we've dropped support for old gccs this would be a lot using
> anonymous unions.

Yup that would be a nice cleanup. SLUB also heavily overloads the 
page_struct. Maybe we need to have some guidelines first on how to avoid 
utter chaos in mm_types.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

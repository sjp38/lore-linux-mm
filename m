Date: Mon, 3 Mar 2008 16:15:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc 05/10] Sparsemem: Vmemmap does not need section bits
In-Reply-To: <20080304091809.b02b1e16.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0803031614510.6741@schroedinger.engr.sgi.com>
References: <20080301040755.268426038@sgi.com> <20080301040814.772847658@sgi.com>
 <20080301133312.9ab8d826.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0803031204170.16049@schroedinger.engr.sgi.com>
 <20080304091809.b02b1e16.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, KAMEZAWA Hiroyuki wrote:

> No. My point is that page_to_section() should return correct number.
> (0 is not correct for pages in some section other than 'section 0')

Ahh. Okay.

> "Now" there are no users of page_to_section() if sparsemem_vmemmap
> is configured. But it seems to be defined as generic function.
> So, someone may use this function in future.

Or we could just not define the function?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 17 Aug 2007 14:07:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] Do not use FASTCALL for __alloc_pages_nodemask()
In-Reply-To: <20070817201848.14792.58117.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708171406520.9635@schroedinger.engr.sgi.com>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
 <20070817201848.14792.58117.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Aug 2007, Mel Gorman wrote:

> Opinions as to why FASTCALL breaks on one machine are welcome.

Could we get rid of FASTCALL? AFAIK the compiler should automatically 
choose the right calling convention?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 27 Sep 2005 16:35:54 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: 2.6.14-rc2 early boot OOPS (mm/slab.c:1767)
In-Reply-To: <20050927202858.GG1046@vega.lnet.lut.fi>
Message-ID: <Pine.LNX.4.62.0509271630050.11040@schroedinger.engr.sgi.com>
References: <20050927202858.GG1046@vega.lnet.lut.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tomi Lapinlampi <lapinlam@vega.lnet.lut.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Tue, 27 Sep 2005, Tomi Lapinlampi wrote:

> I'm getting the following OOPS with 2.6.14-rc2 on an Alpha.

Hmmm. I am not familiar with Alpha. The .config looks as if this is a 
uniprocessor configuration? No NUMA? 

What is the value of MAX_NUMNODES?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

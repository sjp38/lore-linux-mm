Date: Wed, 9 Jan 2008 22:14:25 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 00/19] VM pageout scalability improvements
Message-ID: <20080109221425.23e200c9@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0801091837310.15509@schroedinger.engr.sgi.com>
References: <20080102224144.885671949@redhat.com>
	<20080102224450.585bf956@bree.surriel.com>
	<Pine.LNX.4.64.0801091837310.15509@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernelporg, linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jan 2008 18:39:15 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:
> On Wed, 2 Jan 2008, Rik van Riel wrote:
> 
> > Running a 16000 MB fillmem on my 16GB test box (where slub
> > eats up unexplainable amounts of memory so the test gets about
> > 14GB RSS and 1.5GB in swap).
> 
> SLUB eats up process memory? Slab allocations are not charged to the 
> process. But there is new code in mm so there could be a problem 
> somewhere. Could you give me more details?

IIRC /proc/meminfo reported that there were a few hundred MB
in slab, despite the system only running the few daemons that
get started by default and my one fillmem process.

I'll get you more details once /proc/slabinfo works again.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

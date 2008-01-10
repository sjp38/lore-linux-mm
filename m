Date: Wed, 9 Jan 2008 18:39:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/19] VM pageout scalability improvements
In-Reply-To: <20080102224450.585bf956@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0801091837310.15509@schroedinger.engr.sgi.com>
References: <20080102224144.885671949@redhat.com> <20080102224450.585bf956@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernelporg, linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jan 2008, Rik van Riel wrote:

> Running a 16000 MB fillmem on my 16GB test box (where slub
> eats up unexplainable amounts of memory so the test gets about
> 14GB RSS and 1.5GB in swap).

SLUB eats up process memory? Slab allocations are not charged to the 
process. But there is new code in mm so there could be a problem 
somewhere. Could you give me more details?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

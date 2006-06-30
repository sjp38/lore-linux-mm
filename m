From: Andi Kleen <ak@suse.de>
Subject: Re: ZVC/zone_reclaim: Leave 1% of unmapped pagecache pages for file I/O
Date: Fri, 30 Jun 2006 12:19:19 +0200
References: <Pine.LNX.4.64.0606291949320.30754@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606291949320.30754@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606301219.19473.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, schamp@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 30 June 2006 04:51, Christoph Lameter wrote:
> It turns out that it is advantageous to leave a small portion of
> unmapped file backed pages if a zone is overallocated.
> 
> This allows recently used file I/O buffers to stay on the node and
> reduces the times that zone reclaim is invoked if file I/O occurs
> when we run out of memory in a zone.

Shouldn't that be some kind of tunable? Magic numbers are bad.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

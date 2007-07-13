From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [PATCH 0/7] Sparsemem Virtual Memmap V5
Date: Fri, 13 Jul 2007 22:08:48 +0200
References: <exportbomb.1184333503@pinky> <Pine.LNX.4.64.0707131001060.21777@schroedinger.engr.sgi.com> <20070713104044.0d090c79.akpm@linux-foundation.org>
In-Reply-To: <20070713104044.0d090c79.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707132208.50631.zippel@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi,

On Friday 13 July 2007, Andrew Morton wrote:

> > Would it be possible to merge this for 2.6.23 (maybe late?).
>
> It would be nice to see a bit of spirited reviewing from the affected arch
> maintainers and mm people...

As far as m68k is concerned I like it, especially that it gets rid of the 
explicit table lookup. :)

bye, Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

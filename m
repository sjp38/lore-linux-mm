From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Date: Sat, 27 Oct 2007 16:08:50 -0700
References: <Pine.LNX.4.64.0709101220001.24735@schroedinger.engr.sgi.com> <1189457286.21778.68.camel@twins> <20071026174409.GA1573@elf.ucw.cz>
In-Reply-To: <20071026174409.GA1573@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710271608.50973.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Friday 26 October 2007 10:44, Peter wrote:
> > ...the way the watermarks work they will be evenly distributed
> > over the appropriate zones. ..

Hi Peter,

The term is "highwater mark" not "high watermark".  A watermark is an 
anti-counterfeiting device printed on paper money.  "Highwater" is how 
high water gets, which I believe is the sense we intend in Linux.  
Therefore any occurrence of "watermark" in the kernel source is a 
spelling mistake, unless it has something to do with printing paper 
money.

While fixing this entrenched terminology abuse in our kernel source may 
be difficult, sticking to the correct English on lkml is quite easy :-)

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

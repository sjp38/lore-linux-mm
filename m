Date: Wed, 16 Aug 2000 20:30:32 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Message-ID: <20000816203032.M19260@redhat.com>
References: <200008161847.LAA84163@google.engr.sgi.com> <200008161839.LAA09544@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200008161839.LAA09544@pizda.ninka.net>; from davem@redhat.com on Wed, Aug 16, 2000 at 11:39:17AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: kanoj@google.engr.sgi.com, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Aug 16, 2000 at 11:39:17AM -0700, David S. Miller wrote:
> 
>    I guess finally, drivers will either get one or a list of
> 
>    1. struct page or
> 
> Make this "struct page and offset", a page is not enough by itself to
> indicate all the necessary information, you need an offset within the
> page as well.

That's exactly what a kiobuf is --- a vector of struct page *s, plus
an arbitrary offset and length.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

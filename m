From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008162222.PAA95137@google.engr.sgi.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Wed, 16 Aug 2000 15:22:07 -0700 (PDT)
In-Reply-To: <20000816192012.K19260@redhat.com> from "Stephen C. Tweedie" at Aug 16, 2000 07:20:12 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Roman Zippel <roman@augan.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davem@redhat.com, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Wed, Aug 16, 2000 at 10:13:21AM -0700, Kanoj Sarcar wrote:
> > 
> > FWIW, Linus was mildly suggesting I implement page_to_phys, to complement
> > virt_to_page.
> 
> It's part of what is necessary if we want to push kiobufs into the
> driver layers.  page_to_pfn is needed to for PAE36 support so that
> PCI64 or dual-address-cycle drivers can handle physical addresses
> longer than 32 bits long.
>

While we are on this topic, something like

#define page_to_phys(page) \
	((((page)-(page)->zone->zone_mem_map) << PAGE_SHIFT) \
	+ ((page)->zone->zone_start_paddr))

should work on all platforms on 2.4. (You might have to add in an
unsigned long long somewhere in there for PAE36).

Kanoj 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

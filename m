Date: Tue, 15 Aug 2000 17:19:54 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Message-ID: <20000815171954.U12218@redhat.com>
References: <200008101718.KAA33467@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200008101718.KAA33467@google.engr.sgi.com>; from kanoj@google.engr.sgi.com on Thu, Aug 10, 2000 at 10:18:49AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davem@redhat.com, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Aug 10, 2000 at 10:18:49AM -0700, Kanoj Sarcar wrote:
> Thought I would send out a quick note about a change I put into test6.
> Basically, to make it easier to implement DISCONTIGMEM systems, the
> concepts of page/mem_map number/index has been killed from the generic
> (non architecture specific) parts of the kernel.

Excellent, this will make it _tons_ easier for me to create new zones
of mem_map arrays on the fly to allow us to create struct pages for
PCI IO-aperture memory (necessary for kiobuf mappings of IO memory).

Thanks!

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Message-ID: <399A4FE4.FA5C397A@augan.com>
Date: Wed, 16 Aug 2000 10:25:08 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <200008101718.KAA33467@google.engr.sgi.com> <20000815171954.U12218@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davem@redhat.com, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Hi,

> Excellent, this will make it _tons_ easier for me to create new zones
> of mem_map arrays on the fly to allow us to create struct pages for
> PCI IO-aperture memory (necessary for kiobuf mappings of IO memory).

A related question: do you already have an idea how the driver interface
for that could look like? I mean, some drivers need a virtual address,
some need the physical address for dma and some of them might need
bounce buffers. E.g. I don't know how to get (quickly) from a page
struct which represents an io mapping to the physical address. Will we
add some generic funtions for this which can be used by drivers or even
let the drivers only specify its requirements and the buffer code will
generate an appropriate io request. I have a few ideas, but I don't know
if already concrete plans exists.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

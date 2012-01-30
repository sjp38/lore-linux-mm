Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 199446B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 14:19:44 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id o1so4702932wic.8
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 11:19:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120128192553.GA16231@obsidianresearch.com>
References: <1327557574-6125-1-git-send-email-roland@kernel.org>
 <alpine.LSU.2.00.1201261133230.1369@eggly.anvils> <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com>
 <CAL1RGDVBR49QrAbkZ0Wa9Gh98HTwjtsQbFQ4Ws3Ra7rEjT1Mng@mail.gmail.com>
 <alpine.LSU.2.00.1201271819260.3402@eggly.anvils> <20120128192553.GA16231@obsidianresearch.com>
From: Roland Dreier <roland@kernel.org>
Date: Mon, 30 Jan 2012 11:19:18 -0800
Message-ID: <CAL1RGDWm6q9SxO_X5PR8Z7_V6wiYmoHqdPfX++8=Ph1v5HiZ6Q@mail.gmail.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages() parameters
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Hugh Dickins <hughd@google.com>, linux-rdma@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Jan 28, 2012 at 11:25 AM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> I know accessing system memory (eg obtained via mmap on
> /sys/bus/pci/devices/0000:00:02.0/resource0) has been asked for in the
> past, and IIRC, the problem was that some of the common code, (GUP?)
> errored on these maps. I don't know if Roland's case is similar.

I think the problem there is that this is done via remap_pfn_range()
or similar, and the mapping has no underlying pages at all.  So we
would need a new interface that gives us different information for
such cases.

This is quite a bit trickier since I don't think the DMA API even has
a way to express getting a "device A" bus address for some memory
that is in a BAR for "device B".  So I'm not trying to address this case
(yet).  First I'd like to deal with as many flavors of page-backed
mappings as I can.

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

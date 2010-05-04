Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 50BC56B0273
	for <linux-mm@kvack.org>; Tue,  4 May 2010 13:46:19 -0400 (EDT)
Date: Tue, 4 May 2010 18:45:07 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Suspicious compilation warning
Message-ID: <20100504174507.GI30601@n2100.arm.linux.org.uk>
References: <k2ncecb6d8f1004191627w3cd36450xf797f746460abb09@mail.gmail.com> <20100420155122.6f2c26eb.akpm@linux-foundation.org> <20100420230719.GB1432@n2100.arm.linux.org.uk> <n2gcecb6d8f1005041035w51dac3c8ke829a4ae8bf7f408@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <n2gcecb6d8f1005041035w51dac3c8ke829a4ae8bf7f408@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Marcelo Jimenez <mroberto@cpti.cetuc.puc-rio.br>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, Yinghai Lu <yinghai@kernel.org>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, May 04, 2010 at 02:35:50PM -0300, Marcelo Jimenez wrote:
> Hi,
> 
> On Tue, Apr 20, 2010 at 20:07, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> >
> > Well, it'll be about this number on everything using sparsemem extreme:
> >
> > #define SECTIONS_PER_ROOT       (PAGE_SIZE / sizeof (struct mem_section))
> >
> > and with only 32 sections, this is going to give a NR_SECTION_ROOTS value
> > of zero.  I think the calculation of NR_SECTIONS_ROOTS is wrong.
> >
> > #define NR_SECTION_ROOTS        (NR_MEM_SECTIONS / SECTIONS_PER_ROOT)
> >
> > Clearly if we have 1 mem section, we want to have one section root, so
> > I think this division should round up any fractional part, thusly:
> >
> > #define NR_SECTION_ROOTS        ((NR_MEM_SECTIONS + SECTIONS_PER_ROOT - 1) / SECTIONS_PER_ROOT)
> 
> Seems correct to me, Is there any idea when this gets committed?

What should be asked is whether it has been tested - if not, can we find
someone who can test and validate the change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

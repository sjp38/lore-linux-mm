Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EC6E56B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 04:27:59 -0400 (EDT)
Message-ID: <4DDA1B18.3080201@ladisch.de>
Date: Mon, 23 May 2011 10:30:16 +0200
From: Clemens Ladisch <clemens@ladisch.de>
MIME-Version: 1.0
Subject: Re: mmap() implementation for pci_alloc_consistent() memory?
References: <BANLkTi==cinS1bZc_ARRbnYT3YD+FQr8gA@mail.gmail.com>	<20110519145921.GE9854@dumpdata.com>	<4DD53E2B.2090002@ladisch.de>	<BANLkTinO1xR4XTN2B325pKCpJ3AjC9YidA@mail.gmail.com>	<4DD60F57.8030000@ladisch.de>	<s5htycp6b25.wl%tiwai@suse.de> <BANLkTi=P6WP-+BiqEwCRTxaNTqNHT988wA@mail.gmail.com>
In-Reply-To: <BANLkTi=P6WP-+BiqEwCRTxaNTqNHT988wA@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Woestenberg <leon.woestenberg@gmail.com>
Cc: Takashi Iwai <tiwai@suse.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Leon Woestenberg wrote:
> Having dma_mmap_coherent() there is good for one or two archs, but how
> can we built portable drivers if the others arch's are still missing?

Easy: Resolve all issues, implement it for all the other arches, and add
it to the official DMA API.

> How would dma_mmap_coherent() look like on x86?

X86 and some others are always coherent; just use vm_insert_page() or
remap_page_range().


Regards,
Clemens

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

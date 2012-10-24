Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 8308E6B0070
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 08:18:38 -0400 (EDT)
From: Mario Smarduch <Mario.Smarduch@huawei.com>
Subject: questions about free_area_init_core(), SPARSEMEM, DMA
Date: Wed, 24 Oct 2012 12:18:34 +0000
Message-ID: <2DDB038789B01B4B80B0D3F1FF7CBDC20645F788@lhreml509-mbb.china.huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>


In frea_area_init_core()
for each zone calculates=20
memmap_pages=3DPAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHIFT;

Which is total memory range zone spans and then it subtracts that value fro=
m
realsize (memory present in zone). I'm bit confused for SPARSEMEM case
where sections not occupied don't have memmap arrays (mem_section[] indexed=
)
allocated. Should not the calculation of memmap_pages above take that into
consideration?

Also related to same function I've notice 'dma_reserve' is hardly defined
anywhere. The boards I've looked at (ARM PBX, PXA) have their kernel
text, data, bss allocated in DMA zone, any reasons why 'dma_reserve' is
not defined to correctly determine zone watermarks and other things later
on?

- Mario

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

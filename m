Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id BC44E6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 04:51:29 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id p61so1452130wes.39
        for <linux-mm@kvack.org>; Thu, 01 Aug 2013 01:51:28 -0700 (PDT)
Message-ID: <51FA2167.7060305@gmail.com>
Date: Thu, 01 Aug 2013 10:50:47 +0200
From: Wladislav Wiebe <wladislav.kw@gmail.com>
MIME-Version: 1.0
Subject: Re: mm/slab: ppc: ubi: kmalloc_slab WARNING / PPC + UBI driver
References: <51F8F827.6020108@gmail.com> <20130731173434.GA27470@blackmetal.musicnaut.iki.fi>
In-Reply-To: <20130731173434.GA27470@blackmetal.musicnaut.iki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: penberg@kernel.org, cl@linux.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, dedekind1@gmail.com, dwmw2@infradead.org, linux-mtd@lists.infradead.org

Hi,

On 31/07/13 19:34, Aaro Koskinen wrote:
> Hi,
> 
> On Wed, Jul 31, 2013 at 01:42:31PM +0200, Wladislav Wiebe wrote:
>> DEBUG: xxx kmalloc_slab, requested 'size' = 8388608, KMALLOC_MAX_SIZE = 4194304
> [...]
> 
> It seems some procfs file is trying to dump 8 MB at a single go. You
> need to fix that to return data in smaller chunks. What file is it?

seems it's coming from DT:
..
DEBUG: xxx seq_path: file path = /proc/device-tree/localbus@5000/flash@0/partition@1/reg
------------[ cut here ]------------
..

need to check if and how it's possible divide it in smaller chunks.
If somebody has suggestions, feel free to comment-)

Thanks & BR
Wladislav Wiebe


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

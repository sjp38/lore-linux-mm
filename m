Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id BCC3C6B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 15:01:11 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id m20so3200708qcx.9
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 12:01:11 -0800 (PST)
Received: from relais.videotron.ca (relais.videotron.ca. [24.201.245.36])
        by mx.google.com with ESMTP id c3si8498576qee.133.2014.01.23.12.01.10
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 12:01:10 -0800 (PST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN; CHARSET=US-ASCII
Received: from yoda.home ([66.130.143.177]) by VL-VM-MR001.ip.videotron.ca
 (Oracle Communications Messaging Exchange Server 7u4-22.01 64bit (built Apr 21
 2011)) with ESMTP id <0MZV001KBE9XIVB0@VL-VM-MR001.ip.videotron.ca> for
 linux-mm@kvack.org; Thu, 23 Jan 2014 15:01:10 -0500 (EST)
Date: Thu, 23 Jan 2014 15:01:09 -0500 (EST)
From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: [PATCH 3/3] ARM: allow kernel to be loaded in middle of phymem
In-reply-to: <20140123193137.GA15937@n2100.arm.linux.org.uk>
Message-id: <alpine.LFD.2.11.1401231443060.1652@knanqh.ubzr>
References: <1390389916-8711-1-git-send-email-wangnan0@huawei.com>
 <1390389916-8711-4-git-send-email-wangnan0@huawei.com>
 <alpine.LFD.2.11.1401231357520.1652@knanqh.ubzr>
 <20140123193137.GA15937@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Wang Nan <wangnan0@huawei.com>, kexec@lists.infradead.org, Eric Biederman <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Geng Hui <hui.geng@huawei.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Thu, 23 Jan 2014, Russell King - ARM Linux wrote:

> On Thu, Jan 23, 2014 at 02:15:07PM -0500, Nicolas Pitre wrote:
> > On Wed, 22 Jan 2014, Wang Nan wrote:
> > 
> > > This patch allows the kernel to be loaded at the middle of kernel awared
> > > physical memory. Before this patch, users must use mem= or device tree to cheat
> > > kernel about the start address of physical memory.
> > > 
> > > This feature is useful in some special cases, for example, building a crash
> > > dump kernel. Without it, kernel command line, atag and devicetree must be
> > > adjusted carefully, sometimes is impossible.
> > 
> > With CONFIG_PATCH_PHYS_VIRT the value for PHYS_OFFSET is determined 
> > dynamically by rounding down the kernel image start address to the 
> > previous 16MB boundary.  In the case of a crash kernel, this might be 
> > cleaner to simply readjust __pv_phys_offset during early boot and call 
> > fixup_pv_table(), and then reserve away the memory from the previous 
> > kernel.  That will let you access that memory directly (with gdb for 
> > example) and no pointer address translation will be required.
> 
> We already have support in the kernel to ignore memory below the calculated
> PHYS_OFFSET.  See 571b14375019c3a66ef70d4d4a7083f4238aca30.

Sure.  Anyway what I'm suggesting above  would require that the crash 
kernel be linked at a different virtual address for that to work.  
That's probably more trouble than simply mapping the otherwise still 
unmapped memory from the crashed kernel.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

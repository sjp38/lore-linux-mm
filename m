Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1CA6B0036
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 14:32:14 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id w10so607659bkz.10
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 11:32:13 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id ko10si8656bkb.252.2014.01.23.11.32.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 11:32:12 -0800 (PST)
Date: Thu, 23 Jan 2014 19:31:37 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 3/3] ARM: allow kernel to be loaded in middle of phymem
Message-ID: <20140123193137.GA15937@n2100.arm.linux.org.uk>
References: <1390389916-8711-1-git-send-email-wangnan0@huawei.com> <1390389916-8711-4-git-send-email-wangnan0@huawei.com> <alpine.LFD.2.11.1401231357520.1652@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1401231357520.1652@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nico@fluxnic.net>
Cc: Wang Nan <wangnan0@huawei.com>, kexec@lists.infradead.org, Eric Biederman <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Geng Hui <hui.geng@huawei.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Thu, Jan 23, 2014 at 02:15:07PM -0500, Nicolas Pitre wrote:
> On Wed, 22 Jan 2014, Wang Nan wrote:
> 
> > This patch allows the kernel to be loaded at the middle of kernel awared
> > physical memory. Before this patch, users must use mem= or device tree to cheat
> > kernel about the start address of physical memory.
> > 
> > This feature is useful in some special cases, for example, building a crash
> > dump kernel. Without it, kernel command line, atag and devicetree must be
> > adjusted carefully, sometimes is impossible.
> 
> With CONFIG_PATCH_PHYS_VIRT the value for PHYS_OFFSET is determined 
> dynamically by rounding down the kernel image start address to the 
> previous 16MB boundary.  In the case of a crash kernel, this might be 
> cleaner to simply readjust __pv_phys_offset during early boot and call 
> fixup_pv_table(), and then reserve away the memory from the previous 
> kernel.  That will let you access that memory directly (with gdb for 
> example) and no pointer address translation will be required.

We already have support in the kernel to ignore memory below the calculated
PHYS_OFFSET.  See 571b14375019c3a66ef70d4d4a7083f4238aca30.

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

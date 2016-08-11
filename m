Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 466CB6B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 06:07:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so128361017pfx.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 03:07:37 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id zy8si2555169pab.68.2016.08.11.03.07.36
        for <linux-mm@kvack.org>;
        Thu, 11 Aug 2016 03:07:36 -0700 (PDT)
Date: Thu, 11 Aug 2016 11:07:32 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: arm64: why set SECTION_SIZE_BITS to 1G size?
Message-ID: <20160811100732.GA18366@e104818-lin.cambridge.arm.com>
References: <57AC490E.4080204@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57AC490E.4080204@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Will Deacon <will.deacon@arm.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, chenjie6@huawei.com

On Thu, Aug 11, 2016 at 05:44:46PM +0800, Xishi Qiu wrote:
> arm64:
> SECTION_SIZE_BITS 30 -----1G
> 
> The memory hotplug(add_memory -->check_hotplug_memory_range) 
> must be aligned with section.So I can not add mem with 64M ...
> Can I modify the SECTION_SIZE_BITS to 26?

There was a patch to reduce this to 27:

http://lkml.kernel.org/g/1465821119-3384-1-git-send-email-jszhang@marvell.com

Also some discussions in this thread on a different patch:

http://lkml.iu.edu/hypermail/linux/kernel/1604.1/03036.html

Does your system really have such small alignment memory blocks?

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4656B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 18:31:31 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so8014200pbc.11
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 15:31:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id wm3si16983406pab.194.2014.01.13.15.31.29
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 15:31:30 -0800 (PST)
Date: Mon, 13 Jan 2014 15:31:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
Message-Id: <20140113153128.6aaffb9af111ba75a7abd4db@linux-foundation.org>
In-Reply-To: <52D3F7E0.3030206@ti.com>
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com>
	<529217C7.6030304@cogentembedded.com>
	<52935762.1080409@ti.com>
	<20131209165044.cf7de2edb8f4205d5ac02ab0@linux-foundation.org>
	<20131210005454.GX4360@n2100.arm.linux.org.uk>
	<52A66826.7060204@ti.com>
	<20140112105958.GA9791@n2100.arm.linux.org.uk>
	<52D2B7C8.4060103@ti.com>
	<20140113123733.GU15937@n2100.arm.linux.org.uk>
	<52D3F7E0.3030206@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, linux-arm-kernel@lists.infradead.org

On Mon, 13 Jan 2014 09:27:44 -0500 Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:

> > It seems to me to be absolutely silly to have code introduce a warning
> > yet push the fix for the warning via a completely different tree...
> > 
> I mixed it up. Sorry. Some how I thought there was some other build
> configuration thrown the same warning with memblock series and hence
> suggested the patch to go via Andrew's tree.

Yes, I too had assumed that the warning was caused by the bootmem
patches in -mm.

But it in fact occurs in Linus's current tree.  I'll drop
mm-arm-fix-arms-__ffs-to-conform-to-avoid-warning-with-no_bootmem.patch
and I'll assume that rmk will fix this up at an appropriate time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

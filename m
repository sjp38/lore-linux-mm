Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 87C466B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:26:08 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so2729995pac.3
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 02:26:08 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ce8si53992408pdb.18.2015.07.29.02.26.07
        for <linux-mm@kvack.org>;
        Wed, 29 Jul 2015 02:26:07 -0700 (PDT)
Date: Wed, 29 Jul 2015 10:25:37 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 0/2] arm64: support initrd outside of mapped RAM
Message-ID: <20150729092536.GI15213@leverpostej>
References: <1438093961-15536-1-git-send-email-msalter@redhat.com>
 <1438161638.3129.4.camel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438161638.3129.4.camel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jon Medhurst (Tixy)" <tixy@linaro.org>
Cc: "msalter@redhat.com" <msalter@redhat.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "Arnd Bergmann <arnd@arndb.de>--cc=Ard Biesheuvel" <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jul 29, 2015 at 10:20:38AM +0100, Jon Medhurst (Tixy) wrote:
> On Tue, 2015-07-28 at 10:32 -0400, Mark Salter wrote:
> > When booting an arm64 kernel w/initrd using UEFI/grub, use of mem= will likely
> > cut off part or all of the initrd. This leaves it outside the kernel linear
> > map which leads to failure when unpacking.
> 
> Have we got a similar issue for the device-tree blob?

Commit 61bd93ce801bb6df ("arm64: use fixmap region for permanent FDT
mapping") [1] solved that for the DTB in v4.2-rc1.

Mark.

[1] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=61bd93ce801bb6df36eda257a9d2d16c02863cdd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD6F6B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 05:18:28 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so66627052pac.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 02:18:28 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id rn8si11162880pab.174.2015.12.03.02.18.27
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 02:18:27 -0800 (PST)
Date: Thu, 3 Dec 2015 10:18:24 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v4 00/13] UEFI boot and runtime services support for
 32-bit ARM
Message-ID: <20151203101823.GA11337@arm.com>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk, linux@arm.linux.org.uk, akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com

Hi Ard,

On Mon, Nov 30, 2015 at 01:28:14PM +0100, Ard Biesheuvel wrote:
> This series adds support for booting the 32-bit ARM kernel directly from
> UEFI firmware using a builtin UEFI stub. It mostly reuses refactored arm64
> code, and the differences (primarily the PE/COFF header and entry point and
> the efi_create_mapping() implementation) are split out into arm64 and ARM
> versions.
> 
> Since I did not receive any further comments in reply to v3 from the people who
> commented on v2, I think this series in now in sufficient shape to be pulled.
> Note that patch #1 touches mm/memblock.c and include/linux/memblock.h, for which
> get_maintainer.pl does not provide a maintainer, so it has been cc'ed to various
> past editors of those files, and to the linux-mm mailing list.
> 
> Since the series affects both arm64 and ARM, it is up to the maintainers to let
> me know how and when they wish to proceed with this. My suggestion would be to
> send out pull request for patches #1 - #5 to the arm64 maintainer, and for the
> whole series to the ARM maintainer. This should keep any conflicts on either
> side confined to the respective maintainer tree, rather then propagating all the
> way to -next.

For the arm64 bits (patches 2-5):

  Acked-by: Will Deacon <will.deacon@arm.com>

I'd really like an ack from the mm crowd on patch 1 before I queue it.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

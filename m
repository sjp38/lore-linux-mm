Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id CA7AD6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 16:25:40 -0500 (EST)
Received: by wmvv187 with SMTP id v187so85083354wmv.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 13:25:40 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id cs9si14243900wjc.106.2015.11.27.13.25.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 13:25:39 -0800 (PST)
Received: by wmww144 with SMTP id w144so71231818wmw.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 13:25:39 -0800 (PST)
Date: Fri, 27 Nov 2015 21:25:37 +0000
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v3 00/13] UEFI boot and runtime services support for
 32-bit ARM
Message-ID: <20151127212537.GD13918@codeblueprint.co.uk>
References: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com

On Mon, 23 Nov, at 10:06:20AM, Ard Biesheuvel wrote:
> This series adds support for booting the 32-bit ARM kernel directly from
> UEFI firmware using a builtin UEFI stub. It mostly reuses refactored arm64
> code, and the differences (primarily the PE/COFF header and entry point and
> the efi_create_mapping() implementation) are split out into arm64 and ARM
> versions.

For the series,

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>

Ard, I think the next EFI area for refactoring could be the pgtable
switching code, since we've now got 3 architectures doing it. If I can
find some time in the new year I'll add a fourth (i386) and try and
pull out the common code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

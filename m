Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 620DB6B0260
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:55:38 -0500 (EST)
Received: by wmvv187 with SMTP id v187so192183489wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:55:38 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id w15si27554304wme.61.2015.11.16.10.55.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Nov 2015 10:55:37 -0800 (PST)
Date: Mon, 16 Nov 2015 18:55:19 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 07/12] ARM: split off core mapping logic from
 create_mapping
Message-ID: <20151116185519.GE8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
 <1447698757-8762-8-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447698757-8762-8-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, matt.fleming@intel.com, will.deacon@arm.com, grant.likely@linaro.org, catalin.marinas@arm.com, mark.rutland@arm.com, leif.lindholm@linaro.org, roy.franz@linaro.org, msalter@redhat.com, ryan.harkin@linaro.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, Nov 16, 2015 at 07:32:32PM +0100, Ard Biesheuvel wrote:
> In order to be able to reuse the core mapping logic of create_mapping
> for mapping the UEFI Runtime Services into a private set of page tables,
> split it off from create_mapping() into a separate function
> __create_mapping which we will wire up in a subsequent patch.

I'm slightly worried about this.  Generally, these functions setup
global mappings.  If you're wanting to have a private set of page
tables for UEFI, and those private page tables contain global
mappings which are different from the mappings in the kernel's page
tables, then you need careful break-TLBflush-make handling when
switching from the kernel's page tables to the private UEFI ones,
and vice versa.

Has this aspect been considered?

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

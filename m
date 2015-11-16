Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id B843B6B0262
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:00:26 -0500 (EST)
Received: by wmww144 with SMTP id w144so123768282wmw.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:00:26 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id g132si24318659wma.124.2015.11.16.11.00.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Nov 2015 11:00:25 -0800 (PST)
Date: Mon, 16 Nov 2015 19:00:03 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 10/12] ARM: only consider memblocks with NOMAP cleared
 for linear mapping
Message-ID: <20151116190003.GG8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
 <1447698757-8762-11-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447698757-8762-11-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, matt.fleming@intel.com, will.deacon@arm.com, grant.likely@linaro.org, catalin.marinas@arm.com, mark.rutland@arm.com, leif.lindholm@linaro.org, roy.franz@linaro.org, msalter@redhat.com, ryan.harkin@linaro.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, Nov 16, 2015 at 07:32:35PM +0100, Ard Biesheuvel wrote:
> Take the new memblock attribute MEMBLOCK_NOMAP into account when
> deciding whether a certain region is or should be covered by the
> kernel direct mapping.

It's probably worth looking at this as a replacement to the way
arm_memblock_steal() works, provided NOMAP doesn't result in the
memory being passed to the kernel allocators.  Thoughts?

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 807B16B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:49:30 -0500 (EST)
Received: by wmdw130 with SMTP id w130so126435821wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:49:30 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id 1si1336897wjs.111.2015.11.16.11.49.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Nov 2015 11:49:29 -0800 (PST)
Date: Mon, 16 Nov 2015 19:49:15 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 01/12] mm/memblock: add MEMBLOCK_NOMAP attribute to
 memblock memory table
Message-ID: <20151116194914.GK8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
 <1447698757-8762-2-git-send-email-ard.biesheuvel@linaro.org>
 <20151116185859.GF8644@n2100.arm.linux.org.uk>
 <CAKv+Gu-COD0eSWqaTfV_QgCDEiBg5Af8FDVx+TMiYuVkqgTrvw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu-COD0eSWqaTfV_QgCDEiBg5Af8FDVx+TMiYuVkqgTrvw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ryan Harkin <ryan.harkin@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Nov 16, 2015 at 08:09:38PM +0100, Ard Biesheuvel wrote:
> The main difference is that memblock_is_memory() still returns true
> for the region. This is useful in some cases, e.g., to decide which
> attributes to use when mapping.

Ok, so we'd need to switch to using memblock_is_map_memory() instead
for pfn_valid() then.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

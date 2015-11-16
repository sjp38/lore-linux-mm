Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 530186B0255
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 15:33:54 -0500 (EST)
Received: by wmww144 with SMTP id w144so126966787wmw.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 12:33:53 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id lm6si48428700wjb.63.2015.11.16.12.33.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 12:33:53 -0800 (PST)
Received: by wmdw130 with SMTP id w130so127936190wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 12:33:52 -0800 (PST)
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org> <1447698757-8762-2-git-send-email-ard.biesheuvel@linaro.org> <20151116185859.GF8644@n2100.arm.linux.org.uk> <CAKv+Gu-COD0eSWqaTfV_QgCDEiBg5Af8FDVx+TMiYuVkqgTrvw@mail.gmail.com> <20151116194914.GK8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0 (1.0)
In-Reply-To: <20151116194914.GK8644@n2100.arm.linux.org.uk>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <35E90006-1E43-4483-8B18-7123E12E68FF@linaro.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH v2 01/12] mm/memblock: add MEMBLOCK_NOMAP attribute to memblock memory table
Date: Mon, 16 Nov 2015 21:33:47 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ryan Harkin <ryan.harkin@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> On 16 nov. 2015, at 20:49, Russell King - ARM Linux <linux@arm.linux.org.u=
k> wrote:
>=20
>> On Mon, Nov 16, 2015 at 08:09:38PM +0100, Ard Biesheuvel wrote:
>> The main difference is that memblock_is_memory() still returns true
>> for the region. This is useful in some cases, e.g., to decide which
>> attributes to use when mapping.
>=20
> Ok, so we'd need to switch to using memblock_is_map_memory() instead
> for pfn_valid() then.

Indeed, as is implemented by 10/12

> --=20
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C17226B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 16:21:58 -0500 (EST)
Received: by wmec201 with SMTP id c201so71307458wme.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 13:21:58 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id t15si50759700wju.169.2015.11.27.13.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 13:21:57 -0800 (PST)
Received: by wmec201 with SMTP id c201so71307229wme.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 13:21:57 -0800 (PST)
Date: Fri, 27 Nov 2015 21:21:55 +0000
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v3 13/13] ARM: add UEFI stub support
Message-ID: <20151127212155.GC13918@codeblueprint.co.uk>
References: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
 <1448269593-20758-14-git-send-email-ard.biesheuvel@linaro.org>
 <20151126104711.GH2765@codeblueprint.co.uk>
 <CAKv+Gu_RC5qG=BGPSEf=j7AV4SbjXELjBxmcboj1oVs-Dn87qw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu_RC5qG=BGPSEf=j7AV4SbjXELjBxmcboj1oVs-Dn87qw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Leif Lindholm <leif.lindholm@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Kuleshov <kuleshovmail@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ryan Harkin <ryan.harkin@linaro.org>, Grant Likely <grant.likely@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>

On Fri, 27 Nov, at 10:38:05AM, Ard Biesheuvel wrote:
> 
> Actually, it is the reservation done a bit earlier that could
> potentially end up at 0x0, and the [compressed] kernel is always at
> least 32 MB up in memory, so that it can be decompressed as close to
> the base of DRAM as possible.
> 
> As far as I can tell, efi_free() deals correctly with allocations at
> address 0x0, and that is the only dealing we have with the
> reservation. So I don't think there is an issue here.

OK, great.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

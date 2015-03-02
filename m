Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id BA1AD6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 10:14:09 -0500 (EST)
Received: by labge10 with SMTP id ge10so30875941lab.12
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 07:14:09 -0800 (PST)
Received: from mx.tkos.co.il (guitar.tcltek.co.il. [192.115.133.116])
        by mx.google.com with ESMTPS id bs17si22779924wjb.133.2015.03.02.07.14.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 07:14:07 -0800 (PST)
Date: Mon, 2 Mar 2015 17:14:00 +0200
From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [RFC PATCH 0/4] make memtest a generic kernel feature
Message-ID: <20150302151400.GI15668@tarshish>
References: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, lauraa@codeaurora.org, arnd@arndb.de, ard.biesheuvel@linaro.org, catalin.marinas@arm.com, will.deacon@arm.com, mingo@redhat.com, hpa@zytor.com, linux@arm.linux.org.uk, tglx@linutronix.de, akpm@linux-foundation.org

Hi Vladimir,

On Mon, Mar 02, 2015 at 02:55:41PM +0000, Vladimir Murzin wrote:
> Memtest is a simple feature which fills the memory with a given set of
> patterns and validates memory contents, if bad memory regions is detected it
> reserves them via memblock API. Since memblock API is widely used by other
> architectures this feature can be enabled outside of x86 world.
> 
> This patch set promotes memtest to live under generic mm umbrella and enables
> memtest feature for arm/arm64.

Please update the architectures list in the 'memtest' entry at 
Documentation/kernel-parameters.txt.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

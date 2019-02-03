Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52173C282DB
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 09:39:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F374A20855
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 09:39:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F374A20855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62F4E8E001D; Sun,  3 Feb 2019 04:39:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DEFB8E001C; Sun,  3 Feb 2019 04:39:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CF928E001D; Sun,  3 Feb 2019 04:39:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 04A0B8E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 04:39:42 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g9so2123582pfe.7
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 01:39:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=nYTyj5Rd+SbsHhnrf2sshdks629AIdKm2l5YdhHRBo4=;
        b=oupjAnAUeKnyQ6TBhw+XnCCZnmKc13gYTU3N02QdL+tpZuJ5w6pAEhhyhBcv8A+oY9
         czKGEHIe2MfV37BYBdEe2vxMNvk+wKyuSkoGhDgmQ1pP8tpYNmTRMptK91SgvbZZb5Yf
         nG0LQgTPDIea1prHKnYDH8y8AgwdgbUuhlxNgBCSGtScNsU1yINpIOukkySs/ek4UqfE
         8uvDSHDzeIzejOi8dZPXRnn2ICafWnhA/pZKz0vYhdj6LonnoIsrZA1qMe8Y1+w26gIR
         V62FCCwrNN70LlORP0BGuoixxzkCNxNj85H8ShACuRKlIxdjXuU2SkpD5wEZfqZ425Jr
         kq/Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukd9/8vkQqMzoKbQm6T4FbFjMNyeaiJnla7vPBMCvbIte5mw/jG+
	vG6Gqbvu2IDzEodzjLl4sZB3jQoBdlV7N+CBkvNmUmOoMsUPUXWbIPiqLqGer0rRH0Z4GCHDE9k
	rsfGzyGQgMZoJp1bI5lBbpAwGvxFSrlZSnpTpHalfTV/FuESVgAKXnEorZc+FvjE=
X-Received: by 2002:a62:6dc7:: with SMTP id i190mr46589807pfc.166.1549186781563;
        Sun, 03 Feb 2019 01:39:41 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7rLi38JEDCUfth6KAtfAyY3kIG9OqYKKS866UZRIHPws8xx/UJsdheZiNSRyVCpr0fzF4j
X-Received: by 2002:a62:6dc7:: with SMTP id i190mr46589783pfc.166.1549186780730;
        Sun, 03 Feb 2019 01:39:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549186780; cv=none;
        d=google.com; s=arc-20160816;
        b=DEiqPQtHYjvfbywV1EjPgZDthtdDfFiuMz0lBvn6CszwCLKj+gs45gtVjEsQQhQQCc
         O2sS4z1RCCDWMaBXZZZdNigtIAbhmm9B1IlQm0K9hebUMPWt06v9O2BFbfGs9kknYGFi
         aUmWUwxCW5sGB3U25wQa4hHKzeOKg0/opId8AaHacKVS2o3JpZjwGRMKZIgbKVmGjyUx
         zAMWRa9M6FvbZi48R+6uIHnDs14ywEeVeoW7V+nLyfqzxfGE+nxM1zYUUULpBXwsxyVz
         Pc0hT9InkULbkkWui8Da0qR1ItOCkEbUXWeQcAJA+7Jt7ihqQ9Gepp1fafigi2yo4JD1
         9R1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=nYTyj5Rd+SbsHhnrf2sshdks629AIdKm2l5YdhHRBo4=;
        b=SX2IsSh+7sK2C+0h32PLWJUbVwuM6WopadZUmmA8c7e0FCKHWKY4PK8oa7uRigO+nC
         5LTIRp5MdK64OCaAxlU5114T6nDxGz1K+CG0cIzxqu95xg8H0cLmvta4VQW8kQdK55IT
         abxA+zWNbci300bKjPncidyUCzS9NgBUvqXkFPEnvsUQw1G0Nb9Fc0Q/O1GXTXpu/dVG
         XgESXUPAKbxnVyP0ISweWzTsrg3mLQFURTOYo7Lqek58ciZaj5/x2jmY6ZRnWB3szb/5
         +gN/c31TNacX6bh9CF/Xt8t+J37eREiHoKYt+FnTU2bJLXCZXDqXy1nqEl0o/p2AF8qN
         ghgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id 72si12747813plb.224.2019.02.03.01.39.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Feb 2019 01:39:40 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43sm550vBPz9sMp;
	Sun,  3 Feb 2019 20:39:19 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas
 <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S.
 Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert
 Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao
 <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner
 <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michal Simek
 <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek
 <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger
 <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King
 <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck
 <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org,
 kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org,
 linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org,
 linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org,
 linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org,
 sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
 x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport
 <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 10/21] memblock: refactor internal allocation functions
In-Reply-To: <1548057848-15136-11-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com> <1548057848-15136-11-git-send-email-rppt@linux.ibm.com>
Date: Sun, 03 Feb 2019 20:39:20 +1100
Message-ID: <87ftt5nrcn.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Rapoport <rppt@linux.ibm.com> writes:

> Currently, memblock has several internal functions with overlapping
> functionality. They all call memblock_find_in_range_node() to find free
> memory and then reserve the allocated range and mark it with kmemleak.
> However, there is difference in the allocation constraints and in fallback
> strategies.
>
> The allocations returning physical address first attempt to find free
> memory on the specified node within mirrored memory regions, then retry on
> the same node without the requirement for memory mirroring and finally fall
> back to all available memory.
>
> The allocations returning virtual address start with clamping the allowed
> range to memblock.current_limit, attempt to allocate from the specified
> node from regions with mirroring and with user defined minimal address. If
> such allocation fails, next attempt is done with node restriction lifted.
> Next, the allocation is retried with minimal address reset to zero and at
> last without the requirement for mirrored regions.
>
> Let's consolidate various fallbacks handling and make them more consistent
> for physical and virtual variants. Most of the fallback handling is moved
> to memblock_alloc_range_nid() and it now handles node and mirror fallbacks.
>
> The memblock_alloc_internal() uses memblock_alloc_range_nid() to get a
> physical address of the allocated range and converts it to virtual address.
>
> The fallback for allocation below the specified minimal address remains in
> memblock_alloc_internal() because memblock_alloc_range_nid() is used by CMA
> with exact requirement for lower bounds.

This is causing problems on some of my machines.

I see NODE_DATA allocations falling back to node 0 when they shouldn't,
or didn't previously.

eg, before:

57990190: (116011251): numa:   NODE_DATA [mem 0xfffe4980-0xfffebfff]
58152042: (116373087): numa:   NODE_DATA [mem 0x8fff90980-0x8fff97fff]

after:

16356872061562: (6296877055): numa:   NODE_DATA [mem 0xfffe4980-0xfffebfff]
16356872079279: (6296894772): numa:   NODE_DATA [mem 0xfffcd300-0xfffd497f]
16356872096376: (6296911869): numa:     NODE_DATA(1) on node 0


On some of my other systems it does that, and then panics because it
can't allocate anything at all:

[    0.000000] numa:   NODE_DATA [mem 0x7ffcaee80-0x7ffcb3fff]
[    0.000000] numa:   NODE_DATA [mem 0x7ffc99d00-0x7ffc9ee7f]
[    0.000000] numa:     NODE_DATA(1) on node 0
[    0.000000] Kernel panic - not syncing: Cannot allocate 20864 bytes for node 16 data
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc4-gccN-next-20190201-gdc4c899 #1
[    0.000000] Call Trace:
[    0.000000] [c0000000011cfca0] [c000000000c11044] dump_stack+0xe8/0x164 (unreliable)
[    0.000000] [c0000000011cfcf0] [c0000000000fdd6c] panic+0x17c/0x3e0
[    0.000000] [c0000000011cfd90] [c000000000f61bc8] initmem_init+0x128/0x260
[    0.000000] [c0000000011cfe60] [c000000000f57940] setup_arch+0x398/0x418
[    0.000000] [c0000000011cfee0] [c000000000f50a94] start_kernel+0xa0/0x684
[    0.000000] [c0000000011cff90] [c00000000000af70] start_here_common+0x1c/0x52c
[    0.000000] Rebooting in 180 seconds..


So there's something going wrong there, I haven't had time to dig into
it though (Sunday night here).

cheers


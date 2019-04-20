Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E3C8C282E3
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 11:00:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 048832087B
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 11:00:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 048832087B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 962746B0003; Sat, 20 Apr 2019 07:00:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 911B86B0006; Sat, 20 Apr 2019 07:00:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 828546B0007; Sat, 20 Apr 2019 07:00:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0BB6B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 07:00:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z7so4978021pgc.1
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 04:00:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=iNGbB8fSiHcqgGQSLy0rLR1syYAd/wEhKdBtAiQZBW0=;
        b=oo9PWlRUIRI9vu18w+O4u3jYS4k1crIUQOpkItAwI/Dg4TApEgdCvv3Ozgs7zVgwwH
         Vwz1hfpsnpt45+WSRFh5SjvagDetsuSw4qAW2I0yOk423xjaneJwuDbCnMJP6Uq+t4Ht
         A2RWeNMO/Z6IwgKoUGjN8uSqWPIYxMR56K2i9nyPRMyM1IB4dh8A2067YvoKRRBcrvh1
         5JH58L7ft8QqqY39OUGIacfiRm1X35dV2Y3ZFFkT/KavfBzGcGaL/GUKTj3wxpF48Pg8
         /eub7furguiMLz7u14QP0H+819/RKLKOm6p8CHjKoBQGetSongI8mGJm0PDrr+xgpd7s
         fKhQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAUM9dOfrEW38QTc3BXxDYcXL+PKBXhbi1nJ0t/kaVozHWD15tt5
	do2/3I4otVy6EENjKzT4zlwkCJ3+EC0kQGzmAVaD5wTjV5VpzsC+CMtAaZ+ch9VwsfMR9BF3Qdj
	oEyBRxkIu9LHvsv72KEAo9gr6V1fCPHCS2szTbv7vtjLud7C2izkqaxgK2sYwM1k=
X-Received: by 2002:a62:ae13:: with SMTP id q19mr6728160pff.152.1555758031896;
        Sat, 20 Apr 2019 04:00:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyHBRoptF56UhXChZkkj+2wATb/UO6WbClzeCSDRc9KEHxto9EqWjOJWTzh65SeBbyEnZC
X-Received: by 2002:a62:ae13:: with SMTP id q19mr6728074pff.152.1555758030889;
        Sat, 20 Apr 2019 04:00:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555758030; cv=none;
        d=google.com; s=arc-20160816;
        b=KtNd37Y8n1M86tqeS/KYuQbybtzXXpuaiiCe0k0ahSVQG6wq+1cEvaEEgEEanEHW56
         YjlbnH74Bl7q5il0BbSNQ9dBrTIdnh/q+RPPMZcVd/YFNDiqYHF2tNMH4FycoLjmCHpv
         t22/diUHM9i/Hcy5LvXfd/NKENgNGtkHxLDWjoLukUzd23sd3WNPx3EXC2END/m+Fa0q
         GkDUsx8t62icbTn1DvlpyPDC5EsEYCH1OXKz6KfcDIj5QUwGp3ByykHXNuzu6m2Zs8vk
         nvzFJnAP/JLL/j8eQe+p6a+ymdU1yeH1XPGynxhWVbkiXxMa9S0oK4/CyLM+l4AlJnL0
         d4yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=iNGbB8fSiHcqgGQSLy0rLR1syYAd/wEhKdBtAiQZBW0=;
        b=sB8OIvKUmXBXHioCuSvkO+iV4kTE3FV5n3AEOuXz9PU0TgexsGrjzOAaZtOiD6tLAG
         72HhXu4beO+z9869RbO6EbdgCVv0g3UYG3Stq4RizDr2o/7qQha3V7l16bhiL5FZo9AA
         QSgF/3xBc8C/2Q42RULpQVGVfzwbfknCScb4dCIC4VuTmsowNnqxR/k9/O1aPVuh+Ra8
         2M9SQCJp1twvThObg2iwPmJRwCEA9zm64kWuxJ0ye4QXDUJiaZdmsm50RICOJav/JAlx
         qX/QNLSMYb6XBUwnJKr+/x3tiZ0USiWbncjSmGB0k+zH5B/B23k1rN+KguRgPjCaBPjK
         leIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id p6si7648435pfd.19.2019.04.20.04.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 20 Apr 2019 04:00:30 -0700 (PDT)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 44mVHV0c1bz9s70;
	Sat, 20 Apr 2019 21:00:21 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, rguenther@suse.de, hjl.tools@gmail.com, yang.shi@linux.alibaba.com, mhocko@suse.com, vbabka@suse.cz, luto@amacapital.net, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, stable@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-um@lists.infradead.org, benh@kernel.crashing.org, paulus@samba.org, linux-arch@vger.kernel.org, gxt@pku.edu.cn, jdike@addtoit.com, richard@nod.at, anton.ivanov@cambridgegreys.com
Subject: Re: [PATCH] [v2] x86/mpx: fix recursive munmap() corruption
In-Reply-To: <20190419194747.5E1AD6DC@viggo.jf.intel.com>
References: <20190419194747.5E1AD6DC@viggo.jf.intel.com>
Date: Sat, 20 Apr 2019 21:00:21 +1000
Message-ID: <878sw5szzu.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen <dave.hansen@linux.intel.com> writes:
> Changes from v1:
>  * Fix compile errors on UML and non-x86 arches
>  * Clarify commit message and Fixes about the origin of the
>    bug and add the impact to powerpc / uml / unicore32
>
> --
>
> This is a bit of a mess, to put it mildly.  But, it's a bug
> that only seems to have showed up in 4.20 but wasn't noticed
> until now because nobody uses MPX.
>
> MPX has the arch_unmap() hook inside of munmap() because MPX
> uses bounds tables that protect other areas of memory.  When
> memory is unmapped, there is also a need to unmap the MPX
> bounds tables.  Barring this, unused bounds tables can eat 80%
> of the address space.
>
> But, the recursive do_munmap() that gets called vi arch_unmap()
> wreaks havoc with __do_munmap()'s state.  It can result in
> freeing populated page tables, accessing bogus VMA state,
> double-freed VMAs and more.
>
> To fix this, call arch_unmap() before __do_unmap() has a chance
> to do anything meaningful.  Also, remove the 'vma' argument
> and force the MPX code to do its own, independent VMA lookup.
>
> == UML / unicore32 impact ==
>
> Remove unused 'vma' argument to arch_unmap().  No functional
> change.
>
> I compile tested this on UML but not unicore32.
>
> == powerpc impact ==
>
> powerpc uses arch_unmap() well to watch for munmap() on the
> VDSO and zeroes out 'current->mm->context.vdso_base'.  Moving
> arch_unmap() makes this happen earlier in __do_munmap().  But,
> 'vdso_base' seems to only be used in perf and in the signal
> delivery that happens near the return to userspace.  I can not
> find any likely impact to powerpc, other than the zeroing
> happening a little earlier.

Yeah I agree.

> powerpc does not use the 'vma' argument and is unaffected by
> its removal.
>
> I compile-tested a 64-bit powerpc defconfig.

Thanks.

cheers


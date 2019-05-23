Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 417CEC282DE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 16:19:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 008BB2175B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 16:19:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="m8wcPZW/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 008BB2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83A9A6B0292; Thu, 23 May 2019 12:19:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EB836B0293; Thu, 23 May 2019 12:19:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DB536B0294; Thu, 23 May 2019 12:19:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36FB26B0292
	for <linux-mm@kvack.org>; Thu, 23 May 2019 12:19:19 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e6so4191647pgl.1
        for <linux-mm@kvack.org>; Thu, 23 May 2019 09:19:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2+mfsT0IrxXQrq4KP/GursXvK0MXxQtwxb9OHCz15y0=;
        b=kXI7WlPqzlNyC0qUxW35RpVdWF4yYVzJdt8RbIVEL3CLYocv07mEvZatqYQLsQU7zd
         EppYe9fY+6rw5luqCvz+lfRYTxaVadso1Y55DRx84UuyWSCN6+9rv13MU58p+flsTgma
         4lQYyQMdmUeNlhsdHk1Q7CUxYpylMfbsF/WkYJWHuIv59D9/iVpefUbILnXtiQOZu8ef
         7GPcFe3Ph2IqTzW8IcyId7JgGJRauZtN8EpWwN9/RTacif3z1Qf4V0HfD9Hbs6fOWT0Q
         q4dYO/jJdeccI83Zg3IfFX7XdOiXlPAsDxzpOMQIF47seM9EbzqXzXPv5LZ5EE8Gu6hi
         6OlA==
X-Gm-Message-State: APjAAAUegH87hTLD6k9meARy17QD9KHsZm0/XZ+++MfEMkKncdNSRXk4
	ax+uqroi9j/9ImkL4NpPwAqWcVFWp1Bo/QuoGTgY/v84mxxQt6FEll6M9hXGYfLZUhOwWMJ/9/G
	geUg/br1osNXrith8RGeYVyoijefcMfauNrwiQYOBpyNTbP01E0jB2ysJ6Ep9iGqRCw==
X-Received: by 2002:a63:4f07:: with SMTP id d7mr48299113pgb.77.1558628358720;
        Thu, 23 May 2019 09:19:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwHpvAOIue1zp+2vLn4DzUJRWgiSihd+icpU5esZrBGAQjLr0Q/IZ8YsYU17zpU998lboG
X-Received: by 2002:a63:4f07:: with SMTP id d7mr48298948pgb.77.1558628357362;
        Thu, 23 May 2019 09:19:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558628357; cv=none;
        d=google.com; s=arc-20160816;
        b=AqJ6bjeLcD85sUTP8FCpTdCimvv2xf/YXKL4gP4Ts74JEU+xsgsHT77ubh8VOpHlwi
         DXaUzxwYdXsmlLUNzL2zGCvWj2rZWjHKeooqFry2+cFQgbgNJDdXZLKV1OBgANsDfy4T
         lfjYeQJxGPbhT10cJuentVRnLfHnd6oYv0DTsDJNdzHZzAYF/NsKtEq8IZ8vud0DKBQz
         V0JeNxxdUvGL23MZH0Px2dQoobyQFiJT9FAMslxtIGUDv85Sff6Uwfo6Af2rMDOBgVYd
         HmFJgorPKHpIZCRPzoiTpr64zOKWCUGr39p9wzqW+1kt8mpGxymdE19lCK6Qulg9G5Iv
         Cx0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2+mfsT0IrxXQrq4KP/GursXvK0MXxQtwxb9OHCz15y0=;
        b=Hf40W+gq0hBrQ237TEObZiT/bI+sgYdRTz0eMY5qHjkL/8JCv7RrR0p9KiCAhBLA6Z
         01o/iDa+bAg1Sub2UAw267nOcO3EycdlNAw0+Odtnm/fQml7nzxxmPed/Yzbyyj69VHv
         eZMWK9ENgwDj7EhyxEp5m3Q8YVJ9EUXKfUbDTDb/bPZfHMBI3OhPPUhBzxbzvxNWS7Ye
         Du337m+4q4tLUIQ30+SPEzelHl5IVamYXjFfJQX4mecfAHM2ZYxqeL6r/UPBC08NyM2s
         ewEkL1dXt6sp84yMDSpzPnKykAvXdvkQ/8DF7ur0trH/RtaBA5V/n7LHEPneuAdF9yvl
         EJjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="m8wcPZW/";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v21si28980276pgb.560.2019.05.23.09.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 09:19:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="m8wcPZW/";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com [209.85.221.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C256B2189D
	for <linux-mm@kvack.org>; Thu, 23 May 2019 16:19:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558628357;
	bh=Wv0O6tMsqxBwrYSLzxmAH+HjOtWLDhHqgQXa2NMoUIM=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=m8wcPZW/M5eX6YmtPExOOjXbCs1Fo1YueQMdcV589nhOSyRRfgxcT1t4ux70n1ALe
	 sdXuQDKIaa0saOhmp7SlCZBenDx2VVUEyRbkHBeLGunh1nk+LkWLYGyCdNi3rQp4CK
	 WzeOTXr3vBI3tiirMj/acZjWjunbW3S/efBcfh08=
Received: by mail-wr1-f41.google.com with SMTP id d9so6973982wrx.0
        for <linux-mm@kvack.org>; Thu, 23 May 2019 09:19:16 -0700 (PDT)
X-Received: by 2002:adf:e90b:: with SMTP id f11mr4069510wrm.291.1558628353521;
 Thu, 23 May 2019 09:19:13 -0700 (PDT)
MIME-Version: 1.0
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <CALCETrU221N6uPmdaj4bRDDsf+Oc5tEfPERuyV24wsYKHn+spA@mail.gmail.com>
 <9638a51c-4295-924f-1852-1783c7f3e82d@virtuozzo.com> <CALCETrUMDTGRtLFocw6vnN___7rkb6r82ULehs0=yQO5PZL8MA@mail.gmail.com>
 <67d1321e-ffd6-24a3-407f-cd26c82e46b8@virtuozzo.com>
In-Reply-To: <67d1321e-ffd6-24a3-407f-cd26c82e46b8@virtuozzo.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 23 May 2019 09:19:01 -0700
X-Gmail-Original-Message-ID: <CALCETrWzuH3=Uh91UeGwpCj28kjQ82Lj2OTuXm7_3d871PyZSA@mail.gmail.com>
Message-ID: <CALCETrWzuH3=Uh91UeGwpCj28kjQ82Lj2OTuXm7_3d871PyZSA@mail.gmail.com>
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, 
	Keith Busch <keith.busch@intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, alexander.h.duyck@linux.intel.com, 
	Weiny Ira <ira.weiny@intel.com>, Andrey Konovalov <andreyknvl@google.com>, arunks@codeaurora.org, 
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@surriel.com>, 
	Kees Cook <keescook@chromium.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Nicholas Piggin <npiggin@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
	Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, 
	Jerome Glisse <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, 
	daniel.m.jordan@oracle.com, Jann Horn <jannh@google.com>, 
	Adam Borowski <kilobyte@angband.pl>, Linux API <linux-api@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 10:44 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> On 21.05.2019 19:43, Andy Lutomirski wrote:
> > On Tue, May 21, 2019 at 8:52 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> >>
> >> On 21.05.2019 17:43, Andy Lutomirski wrote:

> > Do you mean that the code you sent rejects this case?  If so, please
> > document it.  In any case, I looked at the code, and it seems to be
> > trying to handle MAP_SHARED and MAP_ANONYMOUS.  I don't see where it
> > would reject copying a vDSO.
>
> I prohibit all the VMAs, which contain on of flags: VM_HUGETLB|VM_DONTEXPAND|VM_PFNMAP|VM_IO.
> I'll check carefully, whether it's enough for vDSO.

I think you could make the new syscall a lot more comprehensible bg
restricting it to just MAP_ANONYMOUS, by making it unmap the source,
or possibly both.  If the new syscall unmaps the source (in order so
that the source is gone before the newly mapped pages become
accessible), then you avoid issues in which you need to define
sensible semantics for what happens if both copies are accessed
simultaneously.


--Andy


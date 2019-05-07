Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1760C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:31:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84F96205C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:31:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d8zBwAnC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84F96205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24C666B0005; Tue,  7 May 2019 12:31:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FCEA6B0006; Tue,  7 May 2019 12:31:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EB4A6B0007; Tue,  7 May 2019 12:31:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id E35756B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 12:31:23 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id w25so8670647ioc.1
        for <linux-mm@kvack.org>; Tue, 07 May 2019 09:31:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HdcDag0bf4IjXr3oQ80U5L8vdpfE6vzh4djKOZUTxxI=;
        b=XQOWwmVikn1eaL9RuSEcylR6Qw0SmVwUyoLwSQvKx6SSnbf6qwJyhE6BeJk77/mmq9
         ZX/nskPqroDh0dGA6MWnD4nTAJ53QpCPSpXk1kNstVoey6DE1BPD/OCR0f55kcjW2qdo
         3lDSC/Xw2F4tbZMDIqKm44XNJvYRh5Sqxmiyj7vWDdsH9yJwWRWa5cYBvPnLMNk84g03
         jQgZKCJ4k5/mr5p4w1fl0wDdT9MuCtflC5jaigdPR+tX7ePk22IDqk824k4GbU+zqpnv
         WiE89WeZ2QEDnNJxW1MXZudaFLILFWTx4bPPV2D5z44JAglqm7O+yjUg+e7feNmWnLwx
         /qTw==
X-Gm-Message-State: APjAAAUgaju4E4YkAS5fBoQlZCJ5g845qWeQ7S5RO+bJwVn96bQXs+lI
	YLHAlQHmarp+QRqlWLV5Ra+IPG/pidzICRqxXWMdAZiyoEhymP3kILBW10dO3M9EMNqa+QI6Lry
	Q/NRuaQZ1eduQHW0GxGVoNOMlAAsUG8JejI/SXsIqNyWyYCOYE/3SIvOtFe/c3w/sWQ==
X-Received: by 2002:a24:4f4b:: with SMTP id c72mr10787636itb.55.1557246683582;
        Tue, 07 May 2019 09:31:23 -0700 (PDT)
X-Received: by 2002:a24:4f4b:: with SMTP id c72mr10787560itb.55.1557246682563;
        Tue, 07 May 2019 09:31:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557246682; cv=none;
        d=google.com; s=arc-20160816;
        b=vo5yv2IkAyXHq9F/D79pV5w6IQM/hCq/KgKSDiSq1oiEC7CNPo//ze5dDmtI/MOgmk
         aG4fgJUpi3dhLu49FJUrDoaDQOGXBl4Zaf7bKRmRovaZ66WEpCC6pZF8LXGGEiUKpFZ4
         kC1PqC+Od1pn+b0svSvOEehyYEeNX2TOQNob6G9Th9J1U560goE6RK7M9+dwcQUtEKar
         Agi+uvVgnuZJtYh39+zsPv0vDdRrshnL/KzhxD78TCwcMjub1jCoHiIVrhSnyWWcKexD
         +2t8LQU+vpMKERyEY3VE53vaoPYwy6QgoliBPFJiBUduQ+3mLoYPk/27CJH+ycntnG3U
         qFyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HdcDag0bf4IjXr3oQ80U5L8vdpfE6vzh4djKOZUTxxI=;
        b=Ag26ZE60MQl4DmQ3vaXF08hYY0oZTfogmUSyxx8BhozCt/l71edtHf3q0qVwK2Q0fH
         v8pLBGW4dc7xLZJ1dToM5Ha3PjkuhuMmF8RusjNelA4hS2ku+Q/L9S+hXBktIkQ/AKyH
         guCxQUaZtVqG/cwVxi1oWHi+OPRpUIWTgPCw103zoMqOu1hVjDk6jvbt1oES7poeoX8l
         MA8p2RC49UVkBCsQJHDgCfMtZsM9QkCuCTKfzjExSMEjjdInyZPn06nezz0yx4ASPvNz
         LeeBcmDiq25qeOsKVB3WnZlKpdBfEQHiqWV7EKoDlrtaSYlO/LbCSV59oLCngi8/6tEE
         q8rA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d8zBwAnC;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w66sor18849900itb.32.2019.05.07.09.31.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 09:31:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d8zBwAnC;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HdcDag0bf4IjXr3oQ80U5L8vdpfE6vzh4djKOZUTxxI=;
        b=d8zBwAnCH7wUVI7KmuH2Dm4GeSJ2CVS2J6feMijMY7bNAvSwrLtdbQcnx15Y2PAB84
         Q5wC8rvpIXPCIzvd1IB6Me7cHeiof/G4YASOOq/9MiQ65X3Hx4qa0MoBesKx/BfdbD5n
         8Pq1jscYgeQias7h0sbJwGEa2g/xeC1/YuY9zoVZ0YCgQr9obvTKYBZBYuJ7FFEj3Z4z
         IgYfRyQ/+7uZzuFUBPA5Ndpx4ZDAqoTC8/IxfAgZEWe8xTrpTOFwnLsT2Cb4iDHn0pnO
         zqxXN1aXggULxJT+BowYgXgFb02kS3sMAYDfhtqx10xgQ+d+zF95W0lEx6123zZ5eLa2
         LU0g==
X-Google-Smtp-Source: APXvYqwrRhM2NXqqo7rGUDDdcwtaybqL1I98pu0GXC1TCViomXKy36uHt5drGc+qF4QiXVZZU7eohpNYuOZJy0GKpgs=
X-Received: by 2002:a24:b04:: with SMTP id 4mr19257328itd.6.1557246682072;
 Tue, 07 May 2019 09:31:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190507053826.31622-1-sashal@kernel.org> <20190507053826.31622-62-sashal@kernel.org>
In-Reply-To: <20190507053826.31622-62-sashal@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 7 May 2019 09:31:10 -0700
Message-ID: <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
To: Sasha Levin <sashal@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, 
	Mikhail Zaslonko <zaslonko@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, 
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, 
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, Dave Hansen <dave.hansen@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <alexander.levin@microsoft.com>, 
	linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 6, 2019 at 10:40 PM Sasha Levin <sashal@kernel.org> wrote:
>
> From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
>
> [ Upstream commit 2830bf6f05fb3e05bc4743274b806c821807a684 ]
>
> If memory end is not aligned with the sparse memory section boundary,
> the mapping of such a section is only partly initialized.  This may lead
> to VM_BUG_ON due to uninitialized struct page access from
> is_mem_section_removable() or test_pages_in_a_zone() function triggered
> by memory_hotplug sysfs handlers:
>
> Here are the the panic examples:
>  CONFIG_DEBUG_VM=y
>  CONFIG_DEBUG_VM_PGFLAGS=y
>
>  kernel parameter mem=2050M
>  --------------------------
>  page:000003d082008000 is uninitialized and poisoned
>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>  Call Trace:
>  ( test_pages_in_a_zone+0xde/0x160)
>    show_valid_zones+0x5c/0x190
>    dev_attr_show+0x34/0x70
>    sysfs_kf_seq_show+0xc8/0x148
>    seq_read+0x204/0x480
>    __vfs_read+0x32/0x178
>    vfs_read+0x82/0x138
>    ksys_read+0x5a/0xb0
>    system_call+0xdc/0x2d8
>  Last Breaking-Event-Address:
>    test_pages_in_a_zone+0xde/0x160
>  Kernel panic - not syncing: Fatal exception: panic_on_oops
>
>  kernel parameter mem=3075M
>  --------------------------
>  page:000003d08300c000 is uninitialized and poisoned
>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>  Call Trace:
>  ( is_mem_section_removable+0xb4/0x190)
>    show_mem_removable+0x9a/0xd8
>    dev_attr_show+0x34/0x70
>    sysfs_kf_seq_show+0xc8/0x148
>    seq_read+0x204/0x480
>    __vfs_read+0x32/0x178
>    vfs_read+0x82/0x138
>    ksys_read+0x5a/0xb0
>    system_call+0xdc/0x2d8
>  Last Breaking-Event-Address:
>    is_mem_section_removable+0xb4/0x190
>  Kernel panic - not syncing: Fatal exception: panic_on_oops
>
> Fix the problem by initializing the last memory section of each zone in
> memmap_init_zone() till the very end, even if it goes beyond the zone end.
>
> Michal said:
>
> : This has alwways been problem AFAIU.  It just went unnoticed because we
> : have zeroed memmaps during allocation before f7f99100d8d9 ("mm: stop
> : zeroing memory during allocation in vmemmap") and so the above test
> : would simply skip these ranges as belonging to zone 0 or provided a
> : garbage.
> :
> : So I guess we do care for post f7f99100d8d9 kernels mostly and
> : therefore Fixes: f7f99100d8d9 ("mm: stop zeroing memory during
> : allocation in vmemmap")
>
> Link: http://lkml.kernel.org/r/20181212172712.34019-2-zaslonko@linux.ibm.com
> Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
> Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reported-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
> Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Cc: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
> ---
>  mm/page_alloc.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)

Wasn't this patch reverted in Linus's tree for causing a regression on
some platforms? If so I'm not sure we should pull this in as a
candidate for stable should we, or am I missing something?


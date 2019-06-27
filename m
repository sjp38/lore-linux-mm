Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.9 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 281D1C5B577
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 23:47:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D469C208E3
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 23:47:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iIbAJ0+H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D469C208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39CDD6B0005; Thu, 27 Jun 2019 19:47:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34E0A8E0003; Thu, 27 Jun 2019 19:47:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 264098E0002; Thu, 27 Jun 2019 19:47:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E34856B0005
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 19:47:01 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id i33so2316412pld.15
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 16:47:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tqaLuK1L6bNY5cuzUVYngg+bgb4Q6R92tXoWTRxzMkI=;
        b=RNhIvF6Gqtcjih62ZhyY+AJfv6v1y54hKQ2IQ9QndzIJAzuA8Cq2+dG+sbwDVBkMcu
         J8IVeG32h+V/Qm0R4Yl90ESIiXvCIi+LhxYGn8dBmD6PND4Lf+qcxI2y0sK+yK0Bsr7y
         WRDszPmUIJ9z/866liR2ZLTgLZwF2ryMWZtGFBjXB8Ts3LucNGlhJ4DX9ZcMk7UeeLEy
         scEs9bx9S4YqTElcPkzT/6A+IQ4MiAhN3zRt0c33P/N0F6/dz6FnLnIVNY4NYDEkYjHY
         mQY5mBlsr0VghOswayDTdibL/mDPXiVopCrsO6A1367xpZqmcOKlDzWwe9AoNI2vQAgn
         +8wQ==
X-Gm-Message-State: APjAAAWffXRXOftvcfeeVX4tBE5nM8uBjtGVDyjQrNsHJazdbQv7ugfN
	Hh5uukU3a/SqzVFJR+YpJtHQgivmihEFEqEnSkJwW/rLeM95p4cHR0u3/6CV6SW8Twgl3cD4wn4
	728OwfRAuVCjIbxtPSe33D51i/WmPkM6FnC5tGv9GbUiSJDpuXljrBirejfB0WfE=
X-Received: by 2002:a65:56c5:: with SMTP id w5mr6197519pgs.434.1561679221421;
        Thu, 27 Jun 2019 16:47:01 -0700 (PDT)
X-Received: by 2002:a65:56c5:: with SMTP id w5mr6197475pgs.434.1561679220595;
        Thu, 27 Jun 2019 16:47:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561679220; cv=none;
        d=google.com; s=arc-20160816;
        b=pgNWShVMUhjB/0yVxZBkzloDFZ+/BGmWwA2Xp7A0OreCXXi5auZJOmgax3EjU+/JkA
         ULKm1tQ94uadR0+UWSZlN5HoMlc0bHUZ9XqECbCEdGY9AyUZMxM/v1MtyFLzCa1HCZb7
         n182FbpZdn4SW1DiDK0cforCAzXP+6JWPFFPdg/EzrC4a92DGqNtw5xJ5cpid5AZ9UJi
         sPN0N946+XL8zcDQCZ06hKCek0Wjy3WpwDlyKWAyx+7wE8PEZnO7KACLcvDH1nsQXfrC
         KGSROvPJqApq3EqdrczN7wNAJzL0AoWQfe6CCuJmDf8edjmSIplRcwY4ctSUhWEXXqBY
         slXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=tqaLuK1L6bNY5cuzUVYngg+bgb4Q6R92tXoWTRxzMkI=;
        b=RpoxbHOZDbMvG//322echmM19sRb1X2f5rBkxV5zxeRXR1GQjMAQJRX07KQx99nCj2
         HtJvPzqJ4/GYTBSEO5QYHq1MBuSpQ9KnOzxKmYrdZVDLeTp9z6nsMRx+IGGFllYA/etn
         EeT7uC1OT81OTuBP/J7BkTArKZs+zQ4fSl5MRoSCW8jjU6m+JBiKIfV4KAbowu7fr844
         Tyhss9SNcHIwVsZ1KF174AhqSDYlz/2krA+4h/NrA2UMI+3+n0qf38eGyoxwLjO28bMc
         kk2gMYNoppKXUfs8sdUG1sJhpgRuBVWmXfAmm8bWHDYXHhSMXR79tNHl5F1fooYz0Ahx
         3jNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iIbAJ0+H;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cu14sor301404pjb.27.2019.06.27.16.47.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 16:47:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iIbAJ0+H;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=tqaLuK1L6bNY5cuzUVYngg+bgb4Q6R92tXoWTRxzMkI=;
        b=iIbAJ0+HhXrBNS1hsYpHT5C8buG1Mj/g0OAh2U5znFpi+186BSN2teqxdBdTVnG77F
         kdmHZoJFZTmnQcuWpqWSsFQ7aV3JXDpLk2CMUhfdtzimCljVRwmrNReQEth9UZ8hLlJp
         muc1DByzKkRp7dKSApxi5Ni4p2ChvaDByCNBv13j548c+icCoMjfhS6Oh6rl/Va/KCvB
         p7mes9TkQtNb26gesa/N8zHNnrTaGRRtgvjKTr8VcKGMHdr9h7HjZ8ueQi7wmBRV1PcN
         ftvXHt1qCDylmsN++jRgEpNLeXmJCPojhhNR7rTKPKAbVkaC2ruAdiG9DIyM+OD2/SQe
         cBEw==
X-Google-Smtp-Source: APXvYqzpbRDUIvQ5FKcZ778NrsrMCXHQoQCWNiYvEEW/PsDymyV52tRB/FTO9qLcw1VQh1WcXNh5Cg==
X-Received: by 2002:a17:90a:9bc5:: with SMTP id b5mr9330442pjw.109.1561679220004;
        Thu, 27 Jun 2019 16:47:00 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id e6sm197854pfn.71.2019.06.27.16.46.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 16:46:58 -0700 (PDT)
Date: Fri, 28 Jun 2019 08:46:52 +0900
From: Minchan Kim <minchan@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 1/5] mm: introduce MADV_COLD
Message-ID: <20190627234652.GB33052@google.com>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-2-minchan@kernel.org>
 <343599f9-3d99-b74f-1732-368e584fa5ef@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <343599f9-3d99-b74f-1732-368e584fa5ef@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 06:13:36AM -0700, Dave Hansen wrote:
> On 6/27/19 4:54 AM, Minchan Kim wrote:
> > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > MADV_COLD can be used by a process to mark a memory range as not expected
> > to be used in the near future. The hint can help kernel in deciding which
> > pages to evict early during memory pressure.
> > 
> > It works for every LRU pages like MADV_[DONTNEED|FREE]. IOW, It moves
> > 
> > 	active file page -> inactive file LRU
> > 	active anon page -> inacdtive anon LRU
> 
> Is the LRU behavior part of the interface or the implementation?

It's a just implementation. What user should expect with this API is they just
informs to the kernel "this memory in the regions wouldn't access in the near
future" so how kernel will handle memory in there is up to the kernel.

> 
> I ask because we've got something in between tossing something down the
> LRU and swapping it: page migration.  Specifically, on a system with
> slower memory media (like persistent memory) we just migrate a page
> instead of discarding it at reclaim:
> 
> > https://lore.kernel.org/linux-mm/20190321200157.29678-4-keith.busch@intel.com/
> 
> So let's say I have a page I want to evict from DRAM to the next slower
> tier of memory.  Do I use MADV_COLD or MADV_PAGEOUT?  If the LRU
> behavior is part of the interface itself, then MADV_COLD doesn't work.

IMHO, if it's one of storage in the memory hierarchy, that shouldn't be transparent
for the user? What I meant is VM moves inactive pages to the persistent memory
before the reclaiming. IOW, VM would have one more level LRU or extened inactive
LRU to cover the persistent memory.

> 
> Do you think we'll need a third MADV_ flag for our automatic migration
> behavior?  MADV_REALLYCOLD?  MADV_MIGRATEOUT?

I believe it depends on how we abstract the persistent memory of cache hierarchy.
If we abstract it as diffrent storage with DRAM, manybe, that should be part of
other syscall like like move_pages. 
If we abstract it as part of DRAM, that should be part of additional LRU
or extended inactive LRU.


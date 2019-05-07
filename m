Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03658C46470
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:58:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8FAB20656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:58:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bxzD848w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8FAB20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 546BC6B0008; Tue,  7 May 2019 12:58:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F8976B000A; Tue,  7 May 2019 12:58:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E67C6B000C; Tue,  7 May 2019 12:58:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 084796B0008
	for <linux-mm@kvack.org>; Tue,  7 May 2019 12:58:03 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s8so10700098pgk.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 09:58:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=m/ZtGpZ6spMJjyhMNU3qJtFUSj8HS6DFPL+r9pl24ho=;
        b=JhCrPUmjkHisUJJjFshHdxTiIEsbq1zCtczck43AtoWLvtuWK5rWC72XDtwAGhTrKm
         y5jjPIKX6xb7pUrEwQu/wANrKVECV6kgls5+v5WTwyd5lUb9Dsnz+RHJLiO0R1PxrY6h
         JAaCaYQucve/BqDfUBIdnF9K/5Snq4uhkw/JoaTVWYq7mX0pSsCQwUHzIPbWbVEg/qVZ
         KqNqI7x/N2ZpyhaHkNLQpictnGo8kPtlWsKUiezHxh0stO26BWFQm5LSC2/VgTYl1czG
         V3RKDcDaH5Sr7QGJ2o+YiVsw62ujWbv111JRQFZjGkWYr/DONWXvRIirnZJF9MFVQWTD
         ogiw==
X-Gm-Message-State: APjAAAVVrBlVoh9QhbMKJRsGlyJn7ATuJgnB6u7qjPsRn13CcIr9Brre
	mM5N9be96PfRC/eH09nEUqZ11FmlsiJOsKKSn28x1nI9u3BY1LAyUrv1+2xBAd1kRW4LICXVpxP
	W3F4cnd01lI33nRLBCm7z++8AEbNaP67pcR3QGspNrQp31JUkjot7hJqZZ3+KPiZgVA==
X-Received: by 2002:a62:4e86:: with SMTP id c128mr41681490pfb.39.1557248282549;
        Tue, 07 May 2019 09:58:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaENcCUpuKk7p2KVxcN7YB/cq4LjP11rknpveb48Ca1E3k+oldfYuYoht1rbPIU24PZzwz
X-Received: by 2002:a62:4e86:: with SMTP id c128mr41681447pfb.39.1557248281832;
        Tue, 07 May 2019 09:58:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557248281; cv=none;
        d=google.com; s=arc-20160816;
        b=QRYkz07gX1l40xxWnXuuf62YGB6wcqa7hmsnxs/Sc7okU/GEr5++7OJ/Xz+1Dpqux6
         b8Ww/OHk7PFEV8qu4rkbtcLa0KgXt5zKANNyWJOfge1pLZ2Er8mNbgMxQR1s9mJrdIUU
         RIezvrNiUhVRyqpSDa6JOO2Js2FSv6xLzGrQo+Vc9HmuQM+uurfqFmx8qjWlgtWj2n1o
         MWnD5H5HMwwCHQFDj6ag0I35io65BTl9/ET/68m+PlW+Bx8G3nXKF7HK8OA/j1fC9xCn
         UWXlvDuLlTIytgdWGy5GXefDbmJaHSs6HqlwmRe0+AmAFaj9pnG8KyIKfo3G7OLH6OkE
         5Fdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=m/ZtGpZ6spMJjyhMNU3qJtFUSj8HS6DFPL+r9pl24ho=;
        b=iTUvTy2ry5hPjRFAJrqt+T8IRGDsxBmNgEoIDITUBRGG2t+y7IZIcRLZUxXG2GvYAQ
         X3nEtOEJxUhtrBbsyM1sAQxzUr3i81a1AfxykPV5yBi1Bt5uVLfS43W3wWRk+NbZ9Nwj
         38/lAr5vIEjuGznoL8sBTfK0maXV6J34lQhLZX3v+DuQSGVCaiEvpjF2hUAvHrihj7iW
         qHagaX9ewmf/0BeACCp7lJbXueeWf8aEWr5HirQPRzMv0JzW2lm0O/Ws2AV9L/tMHO/T
         x+BOd7CMt9u8nf7H+fRx36lMF3pZvCu+hMBKIT9BVGXmjKkH1CDZWZw9zv8yc0S0Iwi2
         FnZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bxzD848w;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l95si20430014plb.365.2019.05.07.09.58.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 09:58:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bxzD848w;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3AC28205C9;
	Tue,  7 May 2019 16:58:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557248281;
	bh=k0O6Zge2oYkJ/odPfWebdw/rC3Kt7k/XfPt85IyTuts=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=bxzD848w88aw9JlTkU1D/e4kM4RgnsvgrixKzJEpThPfyJCTdJ4fmEddixgchjZIv
	 vJWsZ5ifLdYumEveNY7R7AK1YEVaPkjXKhwiP30AfFTWrrahCBv8ka1FCwffkp6/ef
	 cM0tDcxxsP38LUAmlv8pQmg5aeclviHWWtHqKMH0=
Date: Tue, 7 May 2019 12:58:00 -0400
From: Sasha Levin <sashal@kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
Message-ID: <20190507165800.GE1747@sasha-vm>
References: <20190507053826.31622-1-sashal@kernel.org>
 <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 09:31:10AM -0700, Alexander Duyck wrote:
>On Mon, May 6, 2019 at 10:40 PM Sasha Levin <sashal@kernel.org> wrote:
>>
>> From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
>>
>> [ Upstream commit 2830bf6f05fb3e05bc4743274b806c821807a684 ]
>>
>> If memory end is not aligned with the sparse memory section boundary,
>> the mapping of such a section is only partly initialized.  This may lead
>> to VM_BUG_ON due to uninitialized struct page access from
>> is_mem_section_removable() or test_pages_in_a_zone() function triggered
>> by memory_hotplug sysfs handlers:
>>
>> Here are the the panic examples:
>>  CONFIG_DEBUG_VM=y
>>  CONFIG_DEBUG_VM_PGFLAGS=y
>>
>>  kernel parameter mem=2050M
>>  --------------------------
>>  page:000003d082008000 is uninitialized and poisoned
>>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>>  Call Trace:
>>  ( test_pages_in_a_zone+0xde/0x160)
>>    show_valid_zones+0x5c/0x190
>>    dev_attr_show+0x34/0x70
>>    sysfs_kf_seq_show+0xc8/0x148
>>    seq_read+0x204/0x480
>>    __vfs_read+0x32/0x178
>>    vfs_read+0x82/0x138
>>    ksys_read+0x5a/0xb0
>>    system_call+0xdc/0x2d8
>>  Last Breaking-Event-Address:
>>    test_pages_in_a_zone+0xde/0x160
>>  Kernel panic - not syncing: Fatal exception: panic_on_oops
>>
>>  kernel parameter mem=3075M
>>  --------------------------
>>  page:000003d08300c000 is uninitialized and poisoned
>>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>>  Call Trace:
>>  ( is_mem_section_removable+0xb4/0x190)
>>    show_mem_removable+0x9a/0xd8
>>    dev_attr_show+0x34/0x70
>>    sysfs_kf_seq_show+0xc8/0x148
>>    seq_read+0x204/0x480
>>    __vfs_read+0x32/0x178
>>    vfs_read+0x82/0x138
>>    ksys_read+0x5a/0xb0
>>    system_call+0xdc/0x2d8
>>  Last Breaking-Event-Address:
>>    is_mem_section_removable+0xb4/0x190
>>  Kernel panic - not syncing: Fatal exception: panic_on_oops
>>
>> Fix the problem by initializing the last memory section of each zone in
>> memmap_init_zone() till the very end, even if it goes beyond the zone end.
>>
>> Michal said:
>>
>> : This has alwways been problem AFAIU.  It just went unnoticed because we
>> : have zeroed memmaps during allocation before f7f99100d8d9 ("mm: stop
>> : zeroing memory during allocation in vmemmap") and so the above test
>> : would simply skip these ranges as belonging to zone 0 or provided a
>> : garbage.
>> :
>> : So I guess we do care for post f7f99100d8d9 kernels mostly and
>> : therefore Fixes: f7f99100d8d9 ("mm: stop zeroing memory during
>> : allocation in vmemmap")
>>
>> Link: http://lkml.kernel.org/r/20181212172712.34019-2-zaslonko@linux.ibm.com
>> Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
>> Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
>> Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
>> Suggested-by: Michal Hocko <mhocko@kernel.org>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> Reported-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
>> Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
>> Cc: Dave Hansen <dave.hansen@intel.com>
>> Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>> Cc: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>> Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
>> ---
>>  mm/page_alloc.c | 12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>
>Wasn't this patch reverted in Linus's tree for causing a regression on
>some platforms? If so I'm not sure we should pull this in as a
>candidate for stable should we, or am I missing something?

I saw a follow-up patch that should be queued too, but I didn't see that
this one got reverted.

--
Thanks,
Sasha


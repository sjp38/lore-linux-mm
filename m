Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DD15C73C63
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:14:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 352012064B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:14:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lgTKjobe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 352012064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEDD68E0060; Tue,  9 Jul 2019 21:14:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9CE38E0032; Tue,  9 Jul 2019 21:14:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8BCA8E0060; Tue,  9 Jul 2019 21:14:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7188E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 21:14:39 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id m25so155351wml.6
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 18:14:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MwwPgMlpib0YNxOhBeaKLTfi6njFAbVNKpSqvnQjupQ=;
        b=KyL2UHbTErh/It7w+zs7fo3pajoLVwp7RWtzgYSv+T/QVhPtmcSVTNn7inNNUffTpk
         +oSoKyV6alm0j1JO2WmR6fNbizN+nTDnZ3czXxg0pmRaHNLFszKqYiOystUrrc5Z/UaU
         fc1SkK1iu9R0x0BOC27QANj+WYpD19IlV9H38RayXExSAq9wYU8Yv49Bdj9c9i3tnaH7
         NsYMRBf6r00QPvmDnJ6ieMZKDWAxZ4pqATOvp8tuIa+XpSRR3Vra3Rf2qhSHHnZvJkI6
         tGXrFQRNkY6PJd5i0O9BNlfjcSSodGvlSLtKiDMVhYdn1D/KgXay8XPOmaJ0e8SDzfq4
         Pd9w==
X-Gm-Message-State: APjAAAUzKCkN3Fa0By/kcq7yjO7dyD7cFH0p4nqkDjz/1M6dToxNFWO7
	zMbmghdlG2kJ1PPrYTD+ES3MpboM4D5dDGHQNb7bmranxYaSojxChreWzfsO4X8ctM5OyQRgv+J
	sMEfb25LVEkSsi7lgAJumsulNJVj7vYmk7re2uaF1g6+o/qAJqcA2r7eSjucitEkcrQ==
X-Received: by 2002:adf:d4c6:: with SMTP id w6mr8001589wrk.98.1562721278754;
        Tue, 09 Jul 2019 18:14:38 -0700 (PDT)
X-Received: by 2002:adf:d4c6:: with SMTP id w6mr8001531wrk.98.1562721277615;
        Tue, 09 Jul 2019 18:14:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562721277; cv=none;
        d=google.com; s=arc-20160816;
        b=Q24V/JXhwb9s+D6ODWUGePM69JoYkMWxUnMZ5QZi3EjO1Ie2acAnvKWsKHrfX1GFSQ
         kBhoA0IzcI3dtz6RG3xligZGguwZLZuxNVC5OqxErEIcdMFCUulwzsuV3jgiDLm62hlp
         37AkMJYUgdVgSt8HpEo1zPNFuO7CijIr3pLUTbfHFFTVS0rcfh2dq9cobGBvHO3xj4+B
         iuWTOR0RufpRIlvRlOnab9oGhg5wL8mHIHUymA/TQOtESF3xtFIMZY6C47yLFVHC9+gA
         jOSfu4fCDQoUVNLFxFMmBxVhD6T5br0ysKyVU+/jotiM1JwaeiB3VxdiA5OfSJUr4CCU
         DpoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MwwPgMlpib0YNxOhBeaKLTfi6njFAbVNKpSqvnQjupQ=;
        b=cTREV25uTBcKJzxlv5RYpDSTcGacME1ypfAu7oIFlybIT2nhD052NUCRD4aB5/8L74
         BqsAbTDPMZ4jV8UuGwAnuOJGsY9oo10ZKexHSn4fMOFds/hZYMNxZxZk0S+Ar9dbB15M
         zRZSQJKEx5FKWk/BWIcFtnZ0gVbVucXhsZblVEBHOiHrDb6N4kQamtCA+P2HU0BAAdte
         4KpDbs9hmujG+8xPnO+UDDjVbzeqIsHI0OQZUQpb4N0ezNT3R1EvLI0szSP29IKcHr9A
         TPnSUi48vMlXzzKp4cxRFVP/PM/0htUCAFDtmxvTB4RX2qDIqTukrQUbPHKBP6YCxq3N
         032g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lgTKjobe;
       spf=pass (google.com: domain of rashmicy@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmicy@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14sor431374wrh.45.2019.07.09.18.14.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jul 2019 18:14:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of rashmicy@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lgTKjobe;
       spf=pass (google.com: domain of rashmicy@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmicy@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MwwPgMlpib0YNxOhBeaKLTfi6njFAbVNKpSqvnQjupQ=;
        b=lgTKjobeSutdAuf3Be1gwrRO4/Zw1Ey6aAPxUlZIB+nlmvvkex+qoSgK/qgUQzc29s
         VWbuhlHQCSB0++Nqgxg/9J9nQnpfNGO/lFe97leaMSVrpzH/bjXM8LGS/e5UYRIOLQBO
         unIIlS2FRMBuDnpGpUCifBQpkgLjRy1Pzoe/lwi3uvsjSku5PBW2EPUiPgdajGMtJmhS
         l2O3vbGNs0ZCI9tCWsaeUSQkXx7Apa3SUneX07y7J+f5wQgBoIXTrR33wyRGjonLkhzo
         rbsJbPptunq7VJS1IN4Y1LStA+LTxFw1Nvm26Gfx5fQOddOAC4qWRamLNG+wqHZ66rX+
         gWfQ==
X-Google-Smtp-Source: APXvYqxB3jc5ZTe0h4/P1Sp2GkiAsAgXwHd859qS9N1zQ5LSog5Z7SFDaPiMZSJJtbrcZj1HvxeeMJ9AOTbWEe/VY+E=
X-Received: by 2002:a5d:4e8a:: with SMTP id e10mr9368339wru.26.1562721276910;
 Tue, 09 Jul 2019 18:14:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190625075227.15193-1-osalvador@suse.de> <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux> <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux> <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
 <20190702074806.GA26836@linux> <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
In-Reply-To: <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
From: Rashmica Gupta <rashmica.g@gmail.com>
Date: Wed, 10 Jul 2019 11:14:25 +1000
Message-ID: <CAC6rBsn5Q1kEB3z2f+wuCfY+=UPWUTRi5Eqyr8GNsv9+BmmDjw@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
To: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com, 
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com, 
	Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Woops, looks like my phone doesn't send plain text emails :/

On Tue, Jul 2, 2019 at 6:52 PM Rashmica Gupta <rashmica.g@gmail.com> wrote:
>
> On Tue, Jul 2, 2019 at 5:48 PM Oscar Salvador <osalvador@suse.de> wrote:
>>
>> On Tue, Jul 02, 2019 at 04:42:34PM +1000, Rashmica Gupta wrote:
>> > Hi David,
>> >
>> > Sorry for the late reply.
>> >
>> > On Wed, 2019-06-26 at 10:28 +0200, David Hildenbrand wrote:
>> > > On 26.06.19 10:15, Oscar Salvador wrote:
>> > > > On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand wrote:
>> > > > > Back then, I already mentioned that we might have some users that
>> > > > > remove_memory() they never added in a granularity it wasn't
>> > > > > added. My
>> > > > > concerns back then were never fully sorted out.
>> > > > >
>> > > > > arch/powerpc/platforms/powernv/memtrace.c
>> > > > >
>> > > > > - Will remove memory in memory block size chunks it never added
>> > > > > - What if that memory resides on a DIMM added via
>> > > > > MHP_MEMMAP_DEVICE?
>> > > > >
>> > > > > Will it at least bail out? Or simply break?
>> > > > >
>> > > > > IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is save
>> > > > > to be
>> > > > > introduced.
>> > > >
>> > > > Uhm, I will take a closer look and see if I can clear your
>> > > > concerns.
>> > > > TBH, I did not try to use arch/powerpc/platforms/powernv/memtrace.c
>> > > > yet.
>> > > >
>> > > > I will get back to you once I tried it out.
>> > > >
>> > >
>> > > BTW, I consider the code in arch/powerpc/platforms/powernv/memtrace.c
>> > > very ugly and dangerous.
>> >
>> > Yes it would be nice to clean this up.
>> >
>> > > We should never allow to manually
>> > > offline/online pages / hack into memory block states.
>> > >
>> > > What I would want to see here is rather:
>> > >
>> > > 1. User space offlines the blocks to be used
>> > > 2. memtrace installs a hotplug notifier and hinders the blocks it
>> > > wants
>> > > to use from getting onlined.
>> > > 3. memory is not added/removed/onlined/offlined in memtrace code.
>> > >
>> >
>> > I remember looking into doing it a similar way. I can't recall the
>> > details but my issue was probably 'how does userspace indicate to
>> > the kernel that this memory being offlined should be removed'?
>> >
>> > I don't know the mm code nor how the notifiers work very well so I
>> > can't quite see how the above would work. I'm assuming memtrace would
>> > register a hotplug notifier and when memory is offlined from userspace,
>> > the callback func in memtrace would be called if the priority was high
>> > enough? But how do we know that the memory being offlined is intended
>> > for usto touch? Is there a way to offline memory from userspace not
>> > using sysfs or have I missed something in the sysfs interface?
>> >
>> > On a second read, perhaps you are assuming that memtrace is used after
>> > adding new memory at runtime? If so, that is not the case. If not, then
>> > would you be able to clarify what I'm not seeing?
>>
>> Hi Rashmica,
>>
>> let us go the easy way here.
>> Could you please explain:
>>
>
> Sure!
>
>>
>> 1) How memtrace works
>
>
>  You write the size of the chunk of memory you want into the debugfs file
> and memtrace will attempt to find a contiguous section of memory of that size
> that can be offlined. If it finds that, then the memory is removed from the
> kernel's mappings. If you want a different size, then you write that to the
> debugsfs file and memtrace will re-add the memory it first removed and then
> try to offline and remove the a chunk of the new size.
>
>
>>
>> 2) Why it was designed, what is the goal of the interface?
>> 3) When it is supposed to be used?
>>
>
> There is a hardware debugging facility (htm) on some power chips. To use
> this you need a contiguous portion of memory for the output to be dumped
> to - and we obviously don't want this memory to be simultaneously used by
> the kernel.
>
> At boot time we can portion off a section of memory for this (and not tell the
> kernel about it), but sometimes you want to be able to use the hardware
> debugging facilities and you haven't done this and you don't want to reboot
> your machine - and memtrace is the solution for this.
>
> If you're curious one tool that uses this debugging facility is here:
> https://github.com/open-power/pdbg. Relevant files are libpdbg/htm.c and src/htm.c.
>
>
>> I have seen a couple of reports in the past from people running memtrace
>> and failing to do so sometimes, and back then I could not grasp why people
>> was using it, or under which circumstances was nice to have.
>> So it would be nice to have a detailed explanation from the person who wrote
>> it.
>>
>
> Is that enough detail?
>
>>
>> Thanks
>>
>> --
>> Oscar Salvador
>> SUSE L3


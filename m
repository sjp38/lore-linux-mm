Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E356C43612
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 02:08:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04C2D21841
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 02:08:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="be7UFB1L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04C2D21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0ECF8E0005; Thu, 10 Jan 2019 21:08:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BDAD8E0001; Thu, 10 Jan 2019 21:08:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AD1E8E0005; Thu, 10 Jan 2019 21:08:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4692D8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:08:55 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id m13so7369660pls.15
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:08:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=Pbs3viVnbLmrJDgZToOWnI2RCPBUPFNlcmEf/PajdJI=;
        b=pj02zMsSjl87A6s1zNUxYwKFA6dZAOP5dEbYOm/ZgR/xypYQ21sQ2087x1lrNGeRaN
         ZWjP2JT2gAelcjKMTDAlSAPuMDEzGP9SRX+YgA+G3q8NGLHi4HdwmuWeFEIzCgEbdGlg
         SLvaV/Rs1+ePcOl3iJYM3H5jOH4iKdQ1Mk66kdtIfLafd/xlas8k+l2yVFyRjjHQbADr
         qeeEYx1GhvWbkdWSyHbSK3DOJ3Dzs0GK+jlQSXkPb+0eQJ4ouNAWrZJZhHb8AP/IeW/I
         cKXj7CFLb8BzuxBvczsYpLNXGhz6TjXmE1iW8yKaSSjf/itd0QBrKDhocfxU2PKMxTKj
         2Cdw==
X-Gm-Message-State: AJcUukf3WYvU2V8m2T5N8Mx6f2gFxinDfSIW6PlidMg/8dDaiAC55g4F
	byr2ZrAd8gis33e4rdK+/5CwiXgBi+b9luZjclliOFj/NjHlCAfRIgoJpxNlItMfxPzxzT4krJZ
	jrla1Wc4mmVfGqhDTY7Yk8LyCwcrI6U7BNLygWKHlCxgiHVHuKE+7XOD/SDPQW589vBWTP/H8Le
	5rOF5ha2gfjGVs4mkLlAC+cprYOwsZEn09DOfwLMrw2DEUuub+W4OsnBLRp8ofvJhSyxvZzqJ55
	iyDAHoNiukSbWoTBfL+X10WVQLROw0bpPOU9gMEIHhVVRrd5vyF9thOv6ZitZc6UmjTiuAo6Xoj
	snpru0wtv9SBEcKhP4wf8b/QiFKuRmKYrttRnUqVbTjw0fBkNSTDxXRBKLKifBG2lkO564LoVQc
	z
X-Received: by 2002:a63:7f4f:: with SMTP id p15mr11723202pgn.296.1547172534818;
        Thu, 10 Jan 2019 18:08:54 -0800 (PST)
X-Received: by 2002:a63:7f4f:: with SMTP id p15mr11723145pgn.296.1547172533935;
        Thu, 10 Jan 2019 18:08:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547172533; cv=none;
        d=google.com; s=arc-20160816;
        b=YzAvs+P/+UEfZRJqI1/mox8HklS0RQTlF/ID+KTdx4LxuZa1mc05J0xQI7raMec2/s
         84o2PrdVIhoorqQp0pnnvU6JcqaFx/6lrsFvxzetcMRH6V2DzwO1LjLPdKemDBaOpSCh
         GKTevcwNMM/sudy0zQWaL+2gqQpO4UHWQ/jxtKU/xJAjGvuKHKhPd1PXstOc+P+E6BAa
         Epy4spxLIR2A8TDay+vZrwM8THDCFrPykP3HPaWvhex42E5AXRRVPjG829LcBgpw5sgL
         Dwwbf43+CNekc5/L7Oql2PI5ULynTDW8hRvmHSipo0WYD+MIBfheqvwS4pg2kYwf6a5R
         q7sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=Pbs3viVnbLmrJDgZToOWnI2RCPBUPFNlcmEf/PajdJI=;
        b=tYBpl9D6Z+BVAudEWiHY8R8syvHKh3ZuhPRy1c8BD66h05btCRx3tTHhTihOab/KYW
         sut0y53unV+v9Gopl8CFTBupsViGm2TPxsAujAz0j+qMWeoVCVkdk6ZuuffRcKDAPPt+
         h6m7Vc9CjcAyAM77BjLiqxs20OZbaAcDdWBiLlptFcw7N0saj/VHimYcGgu2nvbYAoeK
         uK3PXLdvF+RtWOTXBwNhYgHEVmsKOhloAz4W9sEPpveLzVewRiqP88MLN1K/jarP2yD1
         ZFOAY+X8/QwlU8LTS89t58K/qJdKBKsuUBQgk5Keo4gPq68nCWkDyrM7DCWa24ccSdux
         wmVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=be7UFB1L;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j22sor1152364pll.8.2019.01.10.18.08.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 18:08:53 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=be7UFB1L;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=Pbs3viVnbLmrJDgZToOWnI2RCPBUPFNlcmEf/PajdJI=;
        b=be7UFB1LIsM1GXBUnRqgUd1Bg5S47LHTc2yx/D8RMpNdLkrEnNcED8NWgmKomJqmIp
         WYgPN5abdriOnT3SevisE/0NwDFNJm98i7Be+Yrrs7w3sFyh7/lrZVItpBY6kofBUDOu
         pJb1Lh35mDCcDASTBoeUkDycl4LRVlQLpMsmSkvJxeZk/Txd1lR5ry5mibtvseHAiu2p
         RfOEXz8MP2uBBNzf/BVP27ymYip56gz6xvNjqpT11W93MQvBoF0Y3YoSVbzL3KzR5T9t
         4exhZdcdIU4hoVbQE+e9wmpsTGnBFzRbm/SmI7DtE5/CFUvu2vCXhHJEJiD/zifhK4td
         x9Hg==
X-Google-Smtp-Source: ALg8bN4UQkYPpqJKpxWxRaK4cmgmxKZNkNyamVkTWcAR4FwLrPYPdnPfoPvOk/aDS3iWtakkjV8faA==
X-Received: by 2002:a17:902:5588:: with SMTP id g8mr12780632pli.22.1547172532918;
        Thu, 10 Jan 2019 18:08:52 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id v9sm111315757pfg.144.2019.01.10.18.08.49
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 Jan 2019 18:08:50 -0800 (PST)
Date: Thu, 10 Jan 2019 18:08:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Vlastimil Babka <vbabka@suse.cz>
cc: Hugh Dickins <hughd@google.com>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, 
    Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, 
    David Hildenbrand <david@redhat.com>, 
    Mel Gorman <mgorman@techsingularity.net>, 
    David Herrmann <dh.herrmann@gmail.com>, 
    Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, 
    Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, 
    Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, 
    Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is
 migrated
In-Reply-To: <fccdbef6-00cf-38ad-3aa0-9466c9b83176@suse.cz>
Message-ID: <alpine.LSU.2.11.1901101748550.3146@eggly.anvils>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils> <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com> <alpine.LSU.2.11.1811251900300.1278@eggly.anvils> <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
 <fccdbef6-00cf-38ad-3aa0-9466c9b83176@suse.cz>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111020837.dzy69Q5ok_DTt-Uh-Sq-BLxRy6DUqByKNcnJYDguuSw@z>

On Thu, 10 Jan 2019, Vlastimil Babka wrote:
> 
> For the record, anyone backporting this to older kernels should make
> sure to also include 605ca5ede764 ("mm/huge_memory.c: reorder operations
> in __split_huge_page_tail()") or they are in for a lot of fun, like me.

Thanks a lot for alerting us all to this, Vlastimil.  Yes, I consider
Konstantin's 605ca5ede764 a must-have, and so had it already in all
the trees on which I was testing put_and_wait_on_page_locked(),
without being aware of the critical role it was playing.

But you do enjoy fun, don't you? So I shouldn't apologize :)

> 
> Long story [1] short, Konstantin was correct in 605ca5ede764 changelog,
> although it wasn't the main known issue he was fixing:
> 
>   clear_compound_head() also must be called before unfreezing page
>   reference because after successful get_page_unless_zero() might follow
>   put_page() which needs correct compound_head().
> 
> Which is exactly what happens in __migration_entry_wait():
> 
>         if (!get_page_unless_zero(page))
>                 goto out;
>         pte_unmap_unlock(ptep, ptl);
>         put_and_wait_on_page_locked(page); -> does put_page(page)
> 
> while waiting on the THP split (which inserts those migration entries)
> to finish. Before put_and_wait_on_page_locked() it would wait first, and
> only then do put_page() on a page that's no longer tail page, so it
> would work out despite the dangerous get_page_unless_zero() on a tail
> page. Now it doesn't :)

It took me a while to follow there, but yes, agreed.

> 
> Now if only 605ca5ede764 had a CC:stable and a Fixes: tag... Machine
> Learning won this round though, because 605ca5ede764 was added to 4.14
> stable by Sasha...

I'm proud to have passed the Turing test in reverse, but actually
that was me, not ML.  My 173d9d9fd3dd ("mm/huge_memory: splitting set
mapping+index before unfreeze") in 4.20 built upon Konstantin's, so I
included his as a precursor when sending the stable guys pre-XArray
backports.  So Konstantin's is even in 4.9 stable now.

Hugh


Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EEB0C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:54:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 411DE21871
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:54:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="gQuH0Ric"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 411DE21871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6C576B0006; Fri, 26 Jul 2019 08:54:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1F996B0008; Fri, 26 Jul 2019 08:54:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE3FE8E0002; Fri, 26 Jul 2019 08:54:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79CF46B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:54:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i33so28359462pld.15
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:54:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1CV30Ulmhw3UVs5wZJSfxlQX22PQyu6508MpeQYH9hA=;
        b=CnYDsT0iICxsfB3YilexuW9tkEn0zJcXIyLoI3IMNf204VB6gV9ymgDe1zg3teFkBl
         7IhqkM5CMvzMAW6WI9vYLpZs3Bj01ri/7GUTRSYrR6QeKfmX4p6EpUr+k/sxgQa/+QpL
         XiZZK1Fhv0KhrTneyCl1Y7GTCtvtDQTg0hDiPbHm7q/cFXtl/dKyqntSYs/HvXRuOufj
         molqvVBK6fF2c1BJtMpBl1MCbDTQv1lPxoFh2navBy8yTDstA7MYBwDqstV6p62hO7Ht
         cRItkSevuUpTY6dQj8gFcAWIHXnqYOs8yO+3IXvDbKos+0hcUXGsQgEQeOoV1ZdIai0+
         zKAQ==
X-Gm-Message-State: APjAAAVTqK0AJDR6nhKTDUn+gjE2QjsaDkllZq0mDopoxHdBAZmYRRga
	sKoUb/3EN4HNTLOFAUFe7U70Nj0HAaCGlPChSEM5KNNMChY5rTP6FL1wJzDcy6WH2x4h1q2rgsw
	HdZ6bNCttRzzLas0/ntunHaSUbK0TslwaigKi0fJ42FyhD4KnYITM0517p0ebkqaaYQ==
X-Received: by 2002:a63:c44c:: with SMTP id m12mr52569141pgg.396.1564145664967;
        Fri, 26 Jul 2019 05:54:24 -0700 (PDT)
X-Received: by 2002:a63:c44c:: with SMTP id m12mr52569100pgg.396.1564145664153;
        Fri, 26 Jul 2019 05:54:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564145664; cv=none;
        d=google.com; s=arc-20160816;
        b=rDFbqSYsdPtSMb58ueLGBOR9Lon75T3u8EczkH4Y0yCtZdw/whRF0yknb0dc7l2T8K
         /TpGIoFtXSsA0sTO7Nej41Nuu3dTefNNyKdp7w7jjYM42BhMtq4hBOdNMITZQ0dhtk1M
         rZvsHnvsmLD0n1sAqwNZVWO/7o99LL0zNgDnuvwItSP8Ua4zuB9WuOD7PLV/mU5ME6dh
         Osv8jg55CQUikVEluFAe7Lbz+iF+x4xK+Pq4QGmA422mSAx+9cpRNUZi+hNUwM+IU76O
         udlyjTy9FRDjwpOoj/RSH80BDxUd0W8Iwx0QARKg3AdkglpqM2l61EAFhn7oK8lhDd1I
         qO1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1CV30Ulmhw3UVs5wZJSfxlQX22PQyu6508MpeQYH9hA=;
        b=rqzhA57rEiI7Dq6Ngc1hqvLbCFsYUK9ekN8icD3xnU67RQwCWU/zoHjTh56tILkUvX
         vj08j133m+eWrA6L43cuRDewbrHNunBSAWfz/zayM6UJjWoJz61y3615YKN58dSNkYkS
         Lba5ibzPDxaqGz2YAhHTGYshUApxivBCggbXKtcbhjKIgVSyaovmEpPv8Molu8JjgzC6
         5i1D1jiZ1gpmOEbpFJfzNmtyGbKo00yL1MvhAsjNaVVP+JgMc1Zb8BtYuZOmfmT4bUMO
         Z+BsiOHw+PeAjqD2RzUGODhyEmfUCdhXwSX6Gfax3t8oiG5LXCh9Mxu69LNK3m9AT3SA
         kSuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=gQuH0Ric;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 11sor28796299pgh.67.2019.07.26.05.54.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 05:54:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=gQuH0Ric;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1CV30Ulmhw3UVs5wZJSfxlQX22PQyu6508MpeQYH9hA=;
        b=gQuH0RicdNOowMPYfbO1oCrLPCJQ7RG5vRhySY5uKbNmTPgJ9gjJhxIQlgovgpa61j
         /fesyTgUhfC6NkYtNzLPj9OFsHLRlFOnE6bQDcY/2tkHHiMxdFrnqXA8ZynuSTScFhap
         MsVrgmBpEcAREpwym2Gd4zS7Og3lnANQ201d0=
X-Google-Smtp-Source: APXvYqzilkkbU1jvUSqJ7GWTJJgame/K3EOovYUFU8dAxa/kz5mkVmVgYiB/rX3VOXqDrSKNafzHjQ==
X-Received: by 2002:a63:ee0c:: with SMTP id e12mr92603350pgi.184.1564145663513;
        Fri, 26 Jul 2019 05:54:23 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id o129sm23051451pfg.1.2019.07.26.05.54.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 05:54:22 -0700 (PDT)
Date: Fri, 26 Jul 2019 08:54:21 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org,
	vdavydov.dev@gmail.com, Brendan Gregg <bgregg@netflix.com>,
	kernel-team@android.com, Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>, carmenjackson@google.com,
	Christian Hansen <chansen3@cisco.com>,
	Colin Ian King <colin.king@canonical.com>, dancol@google.com,
	David Howells <dhowells@redhat.com>, fmayer@google.com,
	joaodias@google.com, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
	namhyung@google.com, sspatil@google.com
Subject: Re: [PATCH v1 1/2] mm/page_idle: Add support for per-pid page_idle
 using virtual indexing
Message-ID: <20190726125421.GA103959@google.com>
References: <20190722213205.140845-1-joel@joelfernandes.org>
 <20190723061358.GD128252@google.com>
 <20190723142049.GC104199@google.com>
 <20190724042842.GA39273@google.com>
 <20190724141052.GB9945@google.com>
 <c116f836-5a72-c6e6-498f-a904497ef557@yandex-team.ru>
 <20190726000654.GB66718@google.com>
 <9cba9acb-9451-a53e-278d-92f7b66ae20b@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9cba9acb-9451-a53e-278d-92f7b66ae20b@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 02:16:20PM +0300, Konstantin Khlebnikov wrote:
> On 26.07.2019 3:06, Joel Fernandes wrote:
> > On Thu, Jul 25, 2019 at 11:15:53AM +0300, Konstantin Khlebnikov wrote:
> > [snip]
> > > > > > Thanks for bringing up the swapping corner case..  Perhaps we can improve
> > > > > > the heap profiler to detect this by looking at bits 0-4 in pagemap. While it
> > > > > 
> > > > > Yeb, that could work but it could add overhead again what you want to remove?
> > > > > Even, userspace should keep metadata to identify that page was already swapped
> > > > > in last period or newly swapped in new period.
> > > > 
> > > > Yep.
> > > Between samples page could be read from swap and swapped out back multiple times.
> > > For tracking this swap ptes could be marked with idle bit too.
> > > I believe it's not so hard to find free bit for this.
> > > 
> > > Refault\swapout will automatically clear this bit in pte even if
> > > page goes nowhere stays if swap-cache.
> > 
> > Could you clarify more about your idea? Do you mean swapout will clear the new
> > idle swap-pte bit if the page was accessed just before the swapout? >
> > Instead, I thought of using is_swap_pte() to detect if the PTE belong to a
> > page that was swapped. And if so, then assume the page was idle. Sure we
> > would miss data that the page was accessed before the swap out in the
> > sampling window, however if the page was swapped out, then it is likely idle
> > anyway.
> 
> 
> I mean page might be in swap when you mark pages idle and
> then been accessed and swapped back before second pass.
> 
> I propose marking swap pte with idle bit which will be automatically
> cleared by following swapin/swapout pair:
> 
> page alloc -> install page pte
> page swapout -> install swap entry in pte
> mark vm idle -> set swap-idle bit in swap pte
> access/swapin -> install page pte (clear page idle if set)
> page swapout -> install swap entry in pte (without swap idle bit)
> scan vm idle -> see swap entry without idle bit -> page has been accessed since marking idle
> 
> One bit in pte is enough for tracking. This does not needs any propagation for
> idle bits between page and swap, or marking pages as idle in swap cache.

Ok I see the case you are referring to now. This can be a follow-up patch to
address the case, because.. the limitation you mentioned is also something
inherrent in the (traditional) physical page_idle tracking if that were used.
The reason being, after swapping, the PTE is not mapped to any page so there
is nothing to mark as idle. So if the page gets swapped out and in in the
meanwhile, then you would run into the same issue.

But yes, we should certainly address it in the future. I just want to keep
things simple at the moment. I will make a note about your suggestion but you
are welcomed to write a patch for it on top of my patch. I am about to send
another revision shortly for futhre review.

thanks,

 - Joel


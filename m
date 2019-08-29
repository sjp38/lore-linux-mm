Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D6B9C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 17:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46F632339E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 17:03:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DjnaPHpM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46F632339E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B60FF6B0005; Thu, 29 Aug 2019 13:03:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE9A86B000C; Thu, 29 Aug 2019 13:03:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98A716B000D; Thu, 29 Aug 2019 13:03:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0182.hostedemail.com [216.40.44.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6DEAB6B0005
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:03:34 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1BE1C181AC9BA
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 17:03:34 +0000 (UTC)
X-FDA: 75876086748.17.group44_1f178eb6b444a
X-HE-Tag: group44_1f178eb6b444a
X-Filterd-Recvd-Size: 10525
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 17:03:33 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id a13so4505670qtj.1
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 10:03:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZgRU87h5JHA5AkAoqJc+10qT4fOXBtZuv5dlv9B6Vek=;
        b=DjnaPHpMbnBCRVDXMe1hh41uzybkZzxkztnYFFE3lzvTX89vLjc4/FTdQcZy+6HQw1
         HO0bz5YGWi7GKOE8Pgoj+upm+oYJyAIOk0wtz/RhWb8f0G+bkA3Xjqd+Ae+VT0SuV+UF
         ZsMrZkQREGTNBrBTSXPRHWZ3ZKsSWOfvUjuwix71g7qwvsXxHNVjOHlubVADdcEQr6vL
         D6oK3/MG1aBb5AffvDX80fVPAal55jUbpQ+5QBgXWzfGffsabYVx5FQRmgYXv0ThXGQf
         CxpBW4/szPIKxnfAY6scmLMkKfCeqKR2PywfYwEw63P0/Q8zYrUGFpviJwVU0v4O9Lyw
         alkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ZgRU87h5JHA5AkAoqJc+10qT4fOXBtZuv5dlv9B6Vek=;
        b=bOQ1lKgFt2ycRKURjjtOqm7vipa1ID56wWXpAKAhfYWKFrwF8IChErrlNylg5/KQ77
         edWhbyInsVpVdbB2qbM4XUE5iM9FTsDC7Vu3A0vwICHAyX1bPETfDrP4FwZV0C9jlzvT
         oX2D7bk47BNX0hVAZagfNcppFqtrJp+6iBsl+O8ZvBTdDrt9fa6EyVmw+iiPZ0H1m2Al
         8oIxCsXGoA2V+uddOUo8jHRNz1j/7K7OZxI3sa3IxYlKCvb/xnkrrp9rSvg5cWY70j9f
         vHM8AmPEmYGEFjaX95KKcVe6hAgGOJkrLca1zYoVDOTc3Eeiiy4gLyQ2AwEXlsFQWLhj
         WErA==
X-Gm-Message-State: APjAAAUVNLlTRaXY76pWIUNUlCy4dbD5NvSot5Lx0LOPD80GFqWU9Yyj
	2vcvH/IxfCjigAr2q/FfN5uCCSfMi4sLRqILp9o=
X-Google-Smtp-Source: APXvYqzfpryyrhFCigiIB/y5oT7zX5jWIq5gVOf/RY18qyxoRrGZRsqGqizI7DuArE7j6vAl2fsIRmxDZgYbsEcE3sE=
X-Received: by 2002:a05:6214:1447:: with SMTP id b7mr7293617qvy.89.1567098212850;
 Thu, 29 Aug 2019 10:03:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190827110210.lpe36umisqvvesoa@box> <aaaf9742-56f7-44b7-c3db-ad078b7b2220@suse.cz>
 <20190827120923.GB7538@dhcp22.suse.cz> <20190827121739.bzbxjloq7bhmroeq@box>
 <20190827125911.boya23eowxhqmopa@box> <d76ec546-7ae8-23a3-4631-5c531c1b1f40@linux.alibaba.com>
 <20190828075708.GF7386@dhcp22.suse.cz> <20190828140329.qpcrfzg2hmkccnoq@box>
 <20190828141253.GM28313@dhcp22.suse.cz> <20190828144658.ar4fajfuffn6k2ki@black.fi.intel.com>
 <20190828160224.GP28313@dhcp22.suse.cz>
In-Reply-To: <20190828160224.GP28313@dhcp22.suse.cz>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 29 Aug 2019 10:03:21 -0700
Message-ID: <CAHbLzkr4qQKoDP+zsA1_dJcCQE0yfpeKUERMihdpp36awcXOyA@mail.gmail.com>
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	"Kirill A. Shutemov" <kirill@shutemov.name>, Yang Shi <yang.shi@linux.alibaba.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, 
	David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 9:02 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 28-08-19 17:46:59, Kirill A. Shutemov wrote:
> > On Wed, Aug 28, 2019 at 02:12:53PM +0000, Michal Hocko wrote:
> > > On Wed 28-08-19 17:03:29, Kirill A. Shutemov wrote:
> > > > On Wed, Aug 28, 2019 at 09:57:08AM +0200, Michal Hocko wrote:
> > > > > On Tue 27-08-19 10:06:20, Yang Shi wrote:
> > > > > >
> > > > > >
> > > > > > On 8/27/19 5:59 AM, Kirill A. Shutemov wrote:
> > > > > > > On Tue, Aug 27, 2019 at 03:17:39PM +0300, Kirill A. Shutemov wrote:
> > > > > > > > On Tue, Aug 27, 2019 at 02:09:23PM +0200, Michal Hocko wrote:
> > > > > > > > > On Tue 27-08-19 14:01:56, Vlastimil Babka wrote:
> > > > > > > > > > On 8/27/19 1:02 PM, Kirill A. Shutemov wrote:
> > > > > > > > > > > On Tue, Aug 27, 2019 at 08:01:39AM +0200, Michal Hocko wrote:
> > > > > > > > > > > > On Mon 26-08-19 16:15:38, Kirill A. Shutemov wrote:
> > > > > > > > > > > > > Unmapped completely pages will be freed with current code. Deferred split
> > > > > > > > > > > > > only applies to partly mapped THPs: at least on 4k of the THP is still
> > > > > > > > > > > > > mapped somewhere.
> > > > > > > > > > > > Hmm, I am probably misreading the code but at least current Linus' tree
> > > > > > > > > > > > reads page_remove_rmap -> [page_remove_anon_compound_rmap ->\ deferred_split_huge_page even
> > > > > > > > > > > > for fully mapped THP.
> > > > > > > > > > > Well, you read correctly, but it was not intended. I screwed it up at some
> > > > > > > > > > > point.
> > > > > > > > > > >
> > > > > > > > > > > See the patch below. It should make it work as intened.
> > > > > > > > > > >
> > > > > > > > > > > It's not bug as such, but inefficientcy. We add page to the queue where
> > > > > > > > > > > it's not needed.
> > > > > > > > > > But that adding to queue doesn't affect whether the page will be freed
> > > > > > > > > > immediately if there are no more partial mappings, right? I don't see
> > > > > > > > > > deferred_split_huge_page() pinning the page.
> > > > > > > > > > So your patch wouldn't make THPs freed immediately in cases where they
> > > > > > > > > > haven't been freed before immediately, it just fixes a minor
> > > > > > > > > > inefficiency with queue manipulation?
> > > > > > > > > Ohh, right. I can see that in free_transhuge_page now. So fully mapped
> > > > > > > > > THPs really do not matter and what I have considered an odd case is
> > > > > > > > > really happening more often.
> > > > > > > > >
> > > > > > > > > That being said this will not help at all for what Yang Shi is seeing
> > > > > > > > > and we need a more proactive deferred splitting as I've mentioned
> > > > > > > > > earlier.
> > > > > > > > It was not intended to fix the issue. It's fix for current logic. I'm
> > > > > > > > playing with the work approach now.
> > > > > > > Below is what I've come up with. It appears to be functional.
> > > > > > >
> > > > > > > Any comments?
> > > > > >
> > > > > > Thanks, Kirill and Michal. Doing split more proactive is definitely a choice
> > > > > > to eliminate huge accumulated deferred split THPs, I did think about this
> > > > > > approach before I came up with memcg aware approach. But, I thought this
> > > > > > approach has some problems:
> > > > > >
> > > > > > First of all, we can't prove if this is a universal win for the most
> > > > > > workloads or not. For some workloads (as I mentioned about our usecase), we
> > > > > > do see a lot THPs accumulated for a while, but they are very short-lived for
> > > > > > other workloads, i.e. kernel build.
> > > > > >
> > > > > > Secondly, it may be not fair for some workloads which don't generate too
> > > > > > many deferred split THPs or those THPs are short-lived. Actually, the cpu
> > > > > > time is abused by the excessive deferred split THPs generators, isn't it?
> > > > >
> > > > > Yes this is indeed true. Do we have any idea on how much time that
> > > > > actually is?
> > > >
> > > > For uncontented case, splitting 1G worth of pages (2MiB x 512) takes a bit
> > > > more than 50 ms in my setup. But it's best-case scenario: pages not shared
> > > > across multiple processes, no contention on ptl, page lock, etc.
> > >
> > > Any idea about a bad case?
> >
> > Not really.
> >
> > How bad you want it to get? How many processes share the page? Access
> > pattern? Locking situation?
>
> Let's say how hard a regular user can make this?
>
> > Worst case scenarion: no progress on splitting due to pins or locking
> > conflicts (trylock failure).
> >
> > > > > > With memcg awareness, the deferred split THPs actually are isolated and
> > > > > > capped by memcg. The long-lived deferred split THPs can't be accumulated too
> > > > > > many due to the limit of memcg. And, cpu time spent in splitting them would
> > > > > > just account to the memcgs who generate that many deferred split THPs, who
> > > > > > generate them who pay for it. This sounds more fair and we could achieve
> > > > > > much better isolation.
> > > > >
> > > > > On the other hand, deferring the split and free up a non trivial amount
> > > > > of memory is a problem I consider quite serious because it affects not
> > > > > only the memcg workload which has to do the reclaim but also other
> > > > > consumers of memory beucase large memory blocks could be used for higher
> > > > > order allocations.
> > > >
> > > > Maybe instead of drive the split from number of pages on queue we can take
> > > > a hint from compaction that is struggles to get high order pages?
> > >
> > > This is still unbounded in time.
> >
> > I'm not sure we should focus on time.
> >
> > We need to make sure that we don't overal system health worse. Who cares
> > if we have pages on deferred split list as long as we don't have other
> > user for the memory?
>
> We do care for all those users which do not want to get stalled when
> requesting that memory. And you cannot really predict that, right? So
> the sooner the better. Modulo time wasted for the pointless splitting of
> course. I am afraid defining the best timing here is going to be hard
> but let's focus on workloads that are known to generate partial THPs and
> see how that behaves.

I'm supposed we are just concerned by the global memory pressure
incurred by the excessive deferred split THPs. As long as no other
users for that memory we don't have to waste time to care about it.
So, I'm wondering why not we do harder in kswapd?

Currently, deferred split THPs get shrunk like slab. The number of
objects scanned is determined by some factors, i.e. scan priority,
shrinker->seeks, etc, to avoid over reclaim for filesystem caches to
avoid extra I/O. But, we don't have to worry about over reclaim for
deferred split THPs, right? We definitely could shrink them more
aggressively in kswapd context. For example, we could simply set
shrinker->seeks to 0, now it is DEFAULT_SEEKS.

And, we also could consider boost water mark to wake up kswapd earlier
once we see excessive deferred split THPs accumulated.

>
> --
> Michal Hocko
> SUSE Labs
>


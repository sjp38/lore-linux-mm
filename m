Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 872CEC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 13:15:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C57121852
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 13:15:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Tyq+oZU/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C57121852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB9E26B057E; Mon, 26 Aug 2019 09:15:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6AE96B057F; Mon, 26 Aug 2019 09:15:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A816C6B0580; Mon, 26 Aug 2019 09:15:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0156.hostedemail.com [216.40.44.156])
	by kanga.kvack.org (Postfix) with ESMTP id 884226B057E
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 09:15:40 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 313FF4FFA
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:15:40 +0000 (UTC)
X-FDA: 75864626040.09.women63_3165ae98f6706
X-HE-Tag: women63_3165ae98f6706
X-Filterd-Recvd-Size: 9132
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:15:39 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id h8so26463425edv.7
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 06:15:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/98aFtDRUzMMQzgj3hGxbdw5g4xxWHsQPreE+s7Y++8=;
        b=Tyq+oZU/Q97T+VhSiz86va8DU1BPY34C1kPTttITyOw7MtHiPzrMCjS+lHcNFEipf0
         JNINg2s/d8lRjj1fNjTdbJhXNeorLfCbh0TxXZQ8EjmmbYvrzdJOzt4SxB/iGagFXf3g
         642ISLcDS1S3OGdIZ4qx9eoKFApFSRecsh/dueXsJ57vTWE728frcp5hggEAO1DDT3lU
         w7JG+TVnzrn5H9YCks1DZqmzyPWQ5aLzA6tdBiruKXG4VAkSGzwnkMxDY3Y8NZVFAKhz
         RAdB4JV9wFGaNcq0XfFjMtgfxpsmxAUxk7fbAQTX4CuNDbWbxpcXt/Sg5+Abiuj5hhq9
         ZFFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=/98aFtDRUzMMQzgj3hGxbdw5g4xxWHsQPreE+s7Y++8=;
        b=rOiQCE4AxOkIlXpky/cAd5SkUgfEXakjY1FHC++Ufcpis8sopDSjd4rCFuLj4MFQtS
         a6urOAG+SymHciYxcjXIOrlUrK5hnt+qixCDCbVA7Ojv+lOLmiyp5OTbWX/1LkiAlExT
         QMYCXTxyorofuSOd8KVJqDPklCXrj5YWDJ4OuviW+U8X/bJj8yRUG+z1QObKR0noA7tv
         gyT9QycD1dzY9zrT/RVV4tHzlsH/uqnR3fgygkVdlISRMVNZNSMVcGR626GWIxtRycb2
         4dIiaYV797+ko6Fp6xeojUVhqmyNbM9jAYecKEPCAEHa4pEnK1HSUKpXuOyAivjFqdhI
         32LA==
X-Gm-Message-State: APjAAAXzrkm42T1wm8g0YpN7bhmo64PO/Se2VVT7xOCh+lKK0H/YA8fR
	Xo8aafH3C0aHXkgwkWWRZ13wPg==
X-Google-Smtp-Source: APXvYqzJEDEwL3RgLLyfDJ45KqKcx6MamnkrzAd404V/jMnDlt0z5dpvOZXZfa5RQ8KERXKUaxNRBA==
X-Received: by 2002:a17:906:698f:: with SMTP id i15mr16351249ejr.247.1566825337784;
        Mon, 26 Aug 2019 06:15:37 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id o21sm2947871eje.81.2019.08.26.06.15.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Aug 2019 06:15:36 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 5DC6C10050C; Mon, 26 Aug 2019 16:15:38 +0300 (+03)
Date: Mon, 26 Aug 2019 16:15:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com,
	Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
	rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190826131538.64twqx3yexmhp6nf@box>
References: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190822080434.GF12785@dhcp22.suse.cz>
 <ee048bbf-3563-d695-ea58-5f1504aee35c@suse.cz>
 <20190822152934.w6ztolutdix6kbvc@box>
 <20190826074035.GD7538@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826074035.GD7538@dhcp22.suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2019 at 09:40:35AM +0200, Michal Hocko wrote:
> On Thu 22-08-19 18:29:34, Kirill A. Shutemov wrote:
> > On Thu, Aug 22, 2019 at 02:56:56PM +0200, Vlastimil Babka wrote:
> > > On 8/22/19 10:04 AM, Michal Hocko wrote:
> > > > On Thu 22-08-19 01:55:25, Yang Shi wrote:
> > > >> Available memory is one of the most important metrics for memory
> > > >> pressure.
> > > > 
> > > > I would disagree with this statement. It is a rough estimate that tells
> > > > how much memory you can allocate before going into a more expensive
> > > > reclaim (mostly swapping). Allocating that amount still might result in
> > > > direct reclaim induced stalls. I do realize that this is simple metric
> > > > that is attractive to use and works in many cases though.
> > > > 
> > > >> Currently, the deferred split THPs are not accounted into
> > > >> available memory, but they are reclaimable actually, like reclaimable
> > > >> slabs.
> > > >> 
> > > >> And, they seems very common with the common workloads when THP is
> > > >> enabled.  A simple run with MariaDB test of mmtest with THP enabled as
> > > >> always shows it could generate over fifteen thousand deferred split THPs
> > > >> (accumulated around 30G in one hour run, 75% of 40G memory for my VM).
> > > >> It looks worth accounting in MemAvailable.
> > > > 
> > > > OK, this makes sense. But your above numbers are really worrying.
> > > > Accumulating such a large amount of pages that are likely not going to
> > > > be used is really bad. They are essentially blocking any higher order
> > > > allocations and also push the system towards more memory pressure.
> > > > 
> > > > IIUC deferred splitting is mostly a workaround for nasty locking issues
> > > > during splitting, right? This is not really an optimization to cache
> > > > THPs for reuse or something like that. What is the reason this is not
> > > > done from a worker context? At least THPs which would be freed
> > > > completely sound like a good candidate for kworker tear down, no?
> > > 
> > > Agreed that it's a good question. For Kirill :) Maybe with kworker approach we
> > > also wouldn't need the cgroup awareness?
> > 
> > I don't remember a particular locking issue, but I cannot say there's
> > none :P
> > 
> > It's artifact from decoupling PMD split from compound page split: the same
> > page can be mapped multiple times with combination of PMDs and PTEs. Split
> > of one PMD doesn't need to trigger split of all PMDs and underlying
> > compound page.
> > 
> > Other consideration is the fact that page split can fail and we need to
> > have fallback for this case.
> > 
> > Also in most cases THP split would be just waste of time if we would do
> > them at the spot. If you don't have memory pressure it's better to wait
> > until process termination: less pages on LRU is still beneficial.
> 
> This might be true but the reality shows that a lot of THPs might be
> waiting for the memory pressure that is essentially freeable on the
> spot. So I am not really convinced that "less pages on LRUs" is really a
> plausible justification. Can we free at least those THPs which are
> unmapped completely without any pte mappings?

Unmapped completely pages will be freed with current code. Deferred split
only applies to partly mapped THPs: at least on 4k of the THP is still
mapped somewhere.

> > Main source of partly mapped THPs comes from exit path. When PMD mapping
> > of THP got split across multiple VMAs (for instance due to mprotect()),
> > in exit path we unmap PTEs belonging to one VMA just before unmapping the
> > rest of the page. It would be total waste of time to split the page in
> > this scenario.
> > 
> > The whole deferred split thing still looks as a reasonable compromise
> > to me.
> 
> Even when it leads to all other problems mentioned in this and memcg
> deferred reclaim series?

Yes.

You would still need deferred split even if you *try* to split the page on
the spot. split_huge_page() can fail (due to pin on the page) and you will
need to have a way to try again later.

You'll not win anything in complexity by trying split_huge_page()
immediately. I would ague you'll create much more complexity.

> > We may have some kind of watermark and try to keep the number of deferred
> > split THP under it. But it comes with own set of problems: what if all
> > these pages are pinned for really long time and effectively not available
> > for split.
> 
> Again, why cannot we simply push the freeing where there are no other
> mappings? This should be pretty common case, right?

Partly mapped THP is not common case at all.

To get to this point you will need to create a mapping, fault in THP and
then unmap part of it. It requires very active memory management on
application side. This kind of applications usually knows if THP is a fit
for them.

> I am still not sure that waiting for the memory reclaim is a general
> win.

It wins CPU cycles by not doing the work that is likely unneeded.
split_huge_page() is not particularly lightweight operation from locking
and atomic ops POV.

> Do you have any examples of workloads that measurably benefit from
> this lazy approach without any other downsides? In other words how
> exactly do we measure cost/benefit model of this heuristic?

Example? Sure.

Compiling mm/memory.c in my setup generates 8 deferred split. 4 of them
triggered from exit path. The rest 4 comes from MADV_DONTNEED. It doesn't
make sense to convert any of them to in-place split: for short-lived
process any split if waste of time without any benefit.

-- 
 Kirill A. Shutemov


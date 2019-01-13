Return-Path: <SRS0=Nm1P=PV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D1E6C43387
	for <linux-mm@archiver.kernel.org>; Sun, 13 Jan 2019 23:12:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0CB320663
	for <linux-mm@archiver.kernel.org>; Sun, 13 Jan 2019 23:12:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="neGgr+TR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0CB320663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9352E8E0003; Sun, 13 Jan 2019 18:12:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E3FB8E0002; Sun, 13 Jan 2019 18:12:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FB188E0003; Sun, 13 Jan 2019 18:12:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 531C98E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 18:12:50 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id a3so4982926otl.9
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 15:12:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rVGeKOELuMOfy5LTAHKK72fVgmgRLNPAvu1JBzXs4nw=;
        b=l0Vl48FagxhqTl+vwkaicb9tt5qIdptMTz/CQJaingeBxhKLMQTtMTqNtsklYvfvYZ
         OUn6+mZ3Oy8r0QKeL3Y7Nj3QPdpxmxpHQVTCnMgoq/sVAJ4RCrmMIttx5FaXCxrnS1uF
         a8uXA4F2oW91h9wp533r2r7FiPhp3Mrlsy6KRUSa6vulaEbrNE5vNRggwacLVxT66bjr
         5h6uVaSPB7xDYHxfS27R91MnKWzFPJX7eKN/m9iOmUPiMqbP5FSbBSs0qSdSOo9m71Wp
         3J+Z2iFYyMaXR2UK54Nl6C/Z6KOGMnLhXQzPR+uXpD18JARkoXX7lvIgAgEr5Ty+gqle
         JykA==
X-Gm-Message-State: AJcUukemk/thwCqzeFUXoBRzySdtiVhskeFOtrrxUpDToKk3pDSNepP8
	xykM4wCXIiY294NdJgBLF8zEMl5JDKIEcFRvS4xMlSDwpgGL6csJ/0lHOmAyffltXpVcpwwgE/P
	8zFAZxBkpk66lZ05c12t9T3prdol/UEBvsJaSyEk1mpYy2JDP60OTbDLrkyhsBBeA7Zowr/nNzz
	1ntOWoWXf3hqTTeqmYvd0L8IXbWNJ7Qg5qfsyMHkPzMU1iCjDYQ20nPWcebWgX0yYfgqtc68I7T
	m3k46HA7KnkUj5sOj4tDNsDdhap5xDLexQ9nNF8XXjWrjbiea883RkX/EQP8I72auXCiKfnaHsm
	/p32gPqQ0vawAd7leTA30CTiwPzlmrZzbjhGBaZzplZvFjKs2+wwZh0nZA5b/n0wHc6fKYRKZiZ
	X
X-Received: by 2002:aca:ab53:: with SMTP id u80mr15310136oie.261.1547421169963;
        Sun, 13 Jan 2019 15:12:49 -0800 (PST)
X-Received: by 2002:aca:ab53:: with SMTP id u80mr15310125oie.261.1547421169267;
        Sun, 13 Jan 2019 15:12:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547421169; cv=none;
        d=google.com; s=arc-20160816;
        b=wmc4EkVIFt4T9j+BF91XQ7Bu/uC+3nkcRh8GdDN/nXQCRODVvLX4NKuhZOp7HQv7/L
         Op1CvHCNfxiS5C4UevEoRhshj8Wmm1RyXExnkW3mHGYZHkX5OVUVN4PQJODYl0fKjBeN
         WyuBF2J62+qIFdwE+5M/f07ku4uDB52uk4t+QakobWs4S3LEB/Uh/H1mICtBjUj/qjkg
         oQbH4M30MHKRVz2dNnqiYIcli8NB2tulqIa4jUIY7ni3nnTHt04xhE8YeqKtqEVsTQsw
         p/SPhTHhz/jpa3RPk7Z+JZDStcLhEXWVVlkXzMXTLO9y8JrEjywtnlGdzdRN2t+DrRMv
         K+GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rVGeKOELuMOfy5LTAHKK72fVgmgRLNPAvu1JBzXs4nw=;
        b=yokf6BgkPb0deBw8NSDks8hZPcFm2zv5xTAT4twMQ5z4EJdf8o4J+LTVB5h0QjEzpI
         Eb5qtnFzpCjcpOgNJYBmtBHOQkSkj1AfOWN9crSK08gGrtfYG39x3zMj7B28QWjmOC68
         EHnlh/j3CxGvD6IUMk8hW0kfrZEFiv68UdH08WTnCgV28ns2wBXqRjOczxTyNBTNP10l
         WkGLtBk36cbY1hlnzq+AMts618gTPo/YfQzvDN1g/nmNAbxlztFakCr9hX7jbVa5ORZH
         k1RIHqSPloGTR/hwEZ0roFYF5ds4KJsXBNWHIOS5FwK4XOLD5d5vaHvPpMSXCWI5b1mb
         Glxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=neGgr+TR;
       spf=pass (google.com: domain of baptiste.lepers@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=baptiste.lepers@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a28sor2879276otk.13.2019.01.13.15.12.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 Jan 2019 15:12:49 -0800 (PST)
Received-SPF: pass (google.com: domain of baptiste.lepers@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=neGgr+TR;
       spf=pass (google.com: domain of baptiste.lepers@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=baptiste.lepers@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rVGeKOELuMOfy5LTAHKK72fVgmgRLNPAvu1JBzXs4nw=;
        b=neGgr+TR9FkdCEFeWHzV4Z0nZ+OHUHvmFaY9ktQc0NugSzvSGLmqvcmsRUf/X07gTX
         gplKDRkGAIgO2ZQQa9MHy5RNqw338gR6vU4p5e/2lzExpvSS3agv3l1i6hy3tKjLEwWA
         W5NxRcbA+9qYNvL16efxbw656ctC1MhAtYrj4eMDkIvqwlpNzdRD9b49XdSK/Am+aAZw
         2BRK4v5pEV5/mO4d6v+MO+TbDxYSVrlepyyPXVSPLbiqebCePqUkS0gxTcH1kipEe05O
         QiahtkPfptcegGGD7Qi2aOJo8c5alJkMNPlZqM8kbp1nQCpktzGaVekYY1/8B2DtkTQc
         NPcg==
X-Google-Smtp-Source: ALg8bN6o0a84HV6dWAoDG61VKVnzzRxUy/b1vz2dXM5ze884a2cdXvR5WRc/ZidpuwoKRqcBY89XLjnmJDuatAsNtRY=
X-Received: by 2002:a9d:3b65:: with SMTP id z92mr15737265otb.275.1547421168874;
 Sun, 13 Jan 2019 15:12:48 -0800 (PST)
MIME-Version: 1.0
References: <CABdVr8R2y9B+2zzSAT_Ve=BQCa+F+E9_kVH+C28DGpkeQitiog@mail.gmail.com>
 <20190111135938.GG14956@dhcp22.suse.cz> <20190111175301.csgxlwpbsfecuwug@ca-dmjordan1.us.oracle.com>
In-Reply-To: <20190111175301.csgxlwpbsfecuwug@ca-dmjordan1.us.oracle.com>
From: Baptiste Lepers <baptiste.lepers@gmail.com>
Date: Mon, 14 Jan 2019 10:12:37 +1100
Message-ID:
 <CABdVr8T4ccrnRfboehOBfMVG4kHbWwq=ijDOtq3dEbGSXLkyUg@mail.gmail.com>
Subject: Re: Lock overhead in shrink_inactive_list / Slow page reclamation
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, mgorman@techsingularity.net, 
	akpm@linux-foundation.org, dhowells@redhat.com, linux-mm@kvack.org, 
	hannes@cmpxchg.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190113231237.zo9HD_89o4p4-fwGAQg5Srub_ElDoTHypSOV4ZgTRqk@z>

On Sat, Jan 12, 2019 at 4:53 AM Daniel Jordan
<daniel.m.jordan@oracle.com> wrote:
>
> On Fri, Jan 11, 2019 at 02:59:38PM +0100, Michal Hocko wrote:
> > On Fri 11-01-19 16:52:17, Baptiste Lepers wrote:
> > > Hello,
> > >
> > > We have a performance issue with the page cache. One of our workload
> > > spends more than 50% of it's time in the lru_locks called by
> > > shrink_inactive_list in mm/vmscan.c.
> >
> > Who does contend on the lock? Are there direct reclaimers or is it
> > solely kswapd with paths that are faulting the new page cache in?
>
> Yes, and could you please post your performance data showing the time in
> lru_lock?  Whatever you have is fine, but using perf with -g would give
> callstacks and help answer Michal's question about who's contending.

Thanks for the quick answer.

The time spent in the lru_lock is mainly due to direct reclaimers
(reading an mmaped page that causes some readahead to happen). We have
tried to play with readahead values, but it doesn't change performance
a lot. We have disabled swap on the machine, so kwapd doesn't run.

Our programs run in memory cgroups, but I don't think that the issue
directly comes from cgroups (I might be wrong though).

Here is the callchain that I have using perf report --no-children;
(Paste here https://pastebin.com/151x4QhR )

    44.30%  swapper      [kernel.vmlinux]  [k] intel_idle
    # The machine is idle mainly because it waits in that lru_locks,
which is the 2nd function in the report:
    10.98%  testradix    [kernel.vmlinux]  [k] native_queued_spin_lock_slowpath
               |--10.33%--_raw_spin_lock_irq
               |          |
               |           --10.12%--shrink_inactive_list
               |                     shrink_node_memcg
               |                     shrink_node
               |                     do_try_to_free_pages
               |                     try_to_free_mem_cgroup_pages
               |                     try_charge
               |                     mem_cgroup_try_charge
               |                     __add_to_page_cache_locked
               |                     add_to_page_cache_lru
               |                     |
               |                     |--5.39%--ext4_mpage_readpages
               |                     |          ext4_readpages
               |                     |          __do_page_cache_readahead
               |                     |          |
               |                     |           --5.37%--ondemand_readahead
               |                     |
page_cache_async_readahead
               |                     |                     filemap_fault
               |                     |                     ext4_filemap_fault
               |                     |                     __do_fault
               |                     |                     handle_pte_fault
               |                     |                     __handle_mm_fault
               |                     |                     handle_mm_fault
               |                     |                     __do_page_fault
               |                     |                     do_page_fault
               |                     |                     page_fault
               |                     |                     |
               |                     |                     |--4.23%-- <our app>


Thanks,

Baptiste.






>
> Happy to help profile and debug offline.


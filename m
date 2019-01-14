Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93CB1C43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 07:26:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DCD520659
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 07:26:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K8dCsu3U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DCD520659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 949A58E0003; Mon, 14 Jan 2019 02:25:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F93A8E0002; Mon, 14 Jan 2019 02:25:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80F098E0003; Mon, 14 Jan 2019 02:25:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 551FC8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 02:25:59 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id t83so11021303oie.16
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 23:25:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=G/y7nEreV8ZIRCw/bOP8e6RFn+Y0F97m2iwYfbrtTnM=;
        b=NZ4kGl4JNttt92qk/ae+0+79KgfMz94Wc1BjG6APzQDVfeOAMI5mwVftWmnP2+F8eX
         UGlb/1K7N2uYLUqEvtTZfqpjovUM/99mq+Dnruf84CLHRoaj3Y+b6q/13kBQMeQb8eD1
         5+BWlwTRHxqXLfXLzEOZnO3MLJmtn+VSLXH69e+HOUYPjBn1pkYHbxXulHfYO9c/fVzt
         eC0p7SlLjNRr7WTSK+F4pw2TPM1E5zJVeH2xK8k0K/qD71itRWSuTRn6f+zbPfIiRbhV
         5AzxCl4r0wSkLerp6lDDkp9u37juZXdzb2M6VNES589N75Mn5PKLEJhN2eGPgSrHCmLn
         mAdg==
X-Gm-Message-State: AJcUukdnfUm85D/XbdvvlxWzH9mL67oKEz6b3Oi1xyVit1nwvd7ao2e/
	OpEZw7H8KD+8Pc7IYyibo3prOrItfTZ8WdIjXKQ631h/OjVTVMhp0I/3pElcYFiwm9tjF3eLHEr
	Z2Cn2XxM0EeLIa1px+AXk6RV8HLONAR5g7octuRftD3dMem3RgylyNm2TOCztNlHzudJZlx4PfW
	HwBoMEb9hqdmG3qe46gsMnnIuaMAi5MzRQYVdRhMK0DEUlU8hRAlxRdqIsemcKTvWK49GCckQ5u
	P2CHuCf1euKFc92hk/Uawas5XucYy9q0ib7meHOinkCE/ybg4cOzuthoZq6seNHAXtf3hEXgIbz
	Kuyal2uCk/WqohmV6gzouMD5yRVVesF9XcBzVuGMozHG/xCFCoq0Z0PJ2/dPPZy76aki0y809fB
	9
X-Received: by 2002:aca:100b:: with SMTP id 11mr14553106oiq.303.1547450758965;
        Sun, 13 Jan 2019 23:25:58 -0800 (PST)
X-Received: by 2002:aca:100b:: with SMTP id 11mr14553082oiq.303.1547450757970;
        Sun, 13 Jan 2019 23:25:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547450757; cv=none;
        d=google.com; s=arc-20160816;
        b=MJh+iKP1rgSrShFCyAz8VTSna8kZpfjk2g0vUyk6sboxfNRcBtKQ2sMV6uZo3yO9RK
         AmP8Sip6h5tErzorzx9qiJU2O3iP8iLrITCVB23veAATBJ+J7oHYeyr2r6OxE8MdFIu1
         y2K+58iuBreq1BeNWSNoounbPXQw/7Ijf7jq9WlRK2spxVff7aUWOwHyqk8sqWrEuoC4
         xv4MYxQXvDmNyRHmyu5AMiufwKrYfZLHyK91fiioEp5Txo3+Nd2QJQdGQuUsrjgoBw1y
         DShVXQqbrtsCdkTV2iKWeP3h0FJURm5NCGTH2FHUwsmAGVS0lTX3FglcxhtWqbaKIwKW
         tM2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=G/y7nEreV8ZIRCw/bOP8e6RFn+Y0F97m2iwYfbrtTnM=;
        b=RUimQEpNphDVP5t6pNIgJ1eaNxYyi2ONEERW513uCxY9Wv5P3vnkyCZvu+bjQGgsZa
         68tXFTR+2sEiu/NOdhIHTDufKsd5UCQCCN+B5hgU6qTg55pT4m0UlEN1eO5BV1GNZOIa
         AVcMKAQvroChdUc0cWX6SAN79K9Vv1dpfqevTUvlZzzCs3IGclB7txIPJ9FoDP+4UqIH
         juaLQo7/Rl+BXVB5a+Oy09Mag2tt8an7qwfhxzly+o9rewzcLTGe6z3wtSLiNvnL9rCn
         9QFINYipcDUqsfKtTWZiUBkjndk0VBAvzyTcPsPYifPz+3/9WpMegkJkc6801u+/lljY
         PEpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K8dCsu3U;
       spf=pass (google.com: domain of baptiste.lepers@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=baptiste.lepers@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p128sor38287594oia.10.2019.01.13.23.25.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 Jan 2019 23:25:57 -0800 (PST)
Received-SPF: pass (google.com: domain of baptiste.lepers@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K8dCsu3U;
       spf=pass (google.com: domain of baptiste.lepers@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=baptiste.lepers@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=G/y7nEreV8ZIRCw/bOP8e6RFn+Y0F97m2iwYfbrtTnM=;
        b=K8dCsu3U7rWVlQ5Wc45JwiTRCyrMKtYKHbvvt3LauRMeDOgNWDhPZ9z6nu4Ii2kzbp
         dbrPSrraAb/jcvpFrIQy84ZZOnAvNqqkDl8GTVP53egAW0qs4PvmeLb50RWAHl1oWloZ
         XZ8tQfMrOO5pHCH4G+kIEmrFGtQVRisKQn/mcF8Xx7Jln7mQcTl4y6t7J8ZVYT6sTefS
         co/mp9FsfMNbLwtqsoizHC3Ci2+U/YTREV4DPJPeqUK9Yz6QDEUkBy6jX7NEzfRZDFI4
         tuuP41OHEC3MJ8HpxXyvGyBZW3NG1TpOvqhHxCp4fkq6dFtdqUr9staGobRU+zSAUshi
         t2fQ==
X-Google-Smtp-Source: ALg8bN4jkpUkRIFNVapFNG0zv+MMjZRt0TSL4gAGWiL4cLaNNqJb8j0NJ86KpCHevroiylMCSFcaI+zxQ73i8I1pk04=
X-Received: by 2002:aca:2803:: with SMTP id 3mr15042651oix.85.1547450757506;
 Sun, 13 Jan 2019 23:25:57 -0800 (PST)
MIME-Version: 1.0
References: <CABdVr8R2y9B+2zzSAT_Ve=BQCa+F+E9_kVH+C28DGpkeQitiog@mail.gmail.com>
 <20190111135938.GG14956@dhcp22.suse.cz> <20190111175301.csgxlwpbsfecuwug@ca-dmjordan1.us.oracle.com>
 <CABdVr8T4ccrnRfboehOBfMVG4kHbWwq=ijDOtq3dEbGSXLkyUg@mail.gmail.com> <20190114070600.GC21345@dhcp22.suse.cz>
In-Reply-To: <20190114070600.GC21345@dhcp22.suse.cz>
From: Baptiste Lepers <baptiste.lepers@gmail.com>
Date: Mon, 14 Jan 2019 18:25:45 +1100
Message-ID:
 <CABdVr8QT_FS+dFrhDjKu3hfP8TzFXS83DxhX=nTtuLNg3kVckg@mail.gmail.com>
Subject: Re: Lock overhead in shrink_inactive_list / Slow page reclamation
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, mgorman@techsingularity.net, 
	akpm@linux-foundation.org, dhowells@redhat.com, linux-mm@kvack.org, 
	hannes@cmpxchg.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114072545.D_7t5CMgkBiljbRT41DUdWOJceXC5Fep5Rwg94ovEGU@z>

On Mon, Jan 14, 2019 at 6:06 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 14-01-19 10:12:37, Baptiste Lepers wrote:
> > On Sat, Jan 12, 2019 at 4:53 AM Daniel Jordan
> > <daniel.m.jordan@oracle.com> wrote:
> > >
> > > On Fri, Jan 11, 2019 at 02:59:38PM +0100, Michal Hocko wrote:
> > > > On Fri 11-01-19 16:52:17, Baptiste Lepers wrote:
> > > > > Hello,
> > > > >
> > > > > We have a performance issue with the page cache. One of our workload
> > > > > spends more than 50% of it's time in the lru_locks called by
> > > > > shrink_inactive_list in mm/vmscan.c.
> > > >
> > > > Who does contend on the lock? Are there direct reclaimers or is it
> > > > solely kswapd with paths that are faulting the new page cache in?
> > >
> > > Yes, and could you please post your performance data showing the time in
> > > lru_lock?  Whatever you have is fine, but using perf with -g would give
> > > callstacks and help answer Michal's question about who's contending.
> >
> > Thanks for the quick answer.
> >
> > The time spent in the lru_lock is mainly due to direct reclaimers
> > (reading an mmaped page that causes some readahead to happen). We have
> > tried to play with readahead values, but it doesn't change performance
> > a lot. We have disabled swap on the machine, so kwapd doesn't run.
>
> kswapd runs even without swap storage.
>
> > Our programs run in memory cgroups, but I don't think that the issue
> > directly comes from cgroups (I might be wrong though).
>
> Do you use hard/high limit on those cgroups. Because those would be a
> source of the reclaim.
>
> > Here is the callchain that I have using perf report --no-children;
> > (Paste here https://pastebin.com/151x4QhR )
> >
> >     44.30%  swapper      [kernel.vmlinux]  [k] intel_idle
> >     # The machine is idle mainly because it waits in that lru_locks,
> > which is the 2nd function in the report:
> >     10.98%  testradix    [kernel.vmlinux]  [k] native_queued_spin_lock_slowpath
> >                |--10.33%--_raw_spin_lock_irq
> >                |          |
> >                |           --10.12%--shrink_inactive_list
> >                |                     shrink_node_memcg
> >                |                     shrink_node
> >                |                     do_try_to_free_pages
> >                |                     try_to_free_mem_cgroup_pages
> >                |                     try_charge
> >                |                     mem_cgroup_try_charge
>
> And here it shows this is indeed the case. You are hitting the hard
> limit and that causes direct reclaim to shrink the memcg.
>
> If you do not really need a strong isolation between cgroups then I
> would suggest to not set the hard limit and rely on the global memory
> reclaim to do the background reclaim which is less aggressive and more
> pro-active.

Thanks for the suggestion.
We actually need the hard limit in that case, but the problem occurs
even without cgroups (we mmap a 1TB file and we only have 64GB of
RAM). Basically the page cache fills up quickly and then reading the
mmaped file becomes "slow" (400-500MB/s instead of the initial
2.6GB/s). I'm just wondering if there is a way to make page
reclamation a bit faster, especially given that our workload is read
only.

shrink_inactive_list only seem to reclaim 32 pages with the default
setting and takes lru_lock twice to do that, so that's a lock of
locking per KB. Increasing the SWAP_CLUSTER_MAX value helped a bit,
but this is still quite slow.

And thanks for the precision on kwapd, I didn't know it was running
even without swap :)

Baptiste.

> --
> Michal Hocko
> SUSE Labs


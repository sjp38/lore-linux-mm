Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5889C43387
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 22:18:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9177B21934
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 22:18:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SnuvSJOm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9177B21934
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 252388E0014; Fri, 21 Dec 2018 17:18:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 201F08E0001; Fri, 21 Dec 2018 17:18:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 118F28E0014; Fri, 21 Dec 2018 17:18:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4D108E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 17:18:48 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so5544904pgi.14
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 14:18:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=U40y65+ZH6O/HTrNcmmelQb4memE4GhHq1SvommW0g0=;
        b=UEtzzcqH07GyTUY3E17wQMmg3JOF0jwTDIBNutYbKYlwRjg4ZRH/vk9ZLOAOFnP8Xf
         evymsY7xuYd3duBd+bZMjYOZf3Hfh2NFoeTjhEg4rZKknSCkwQYvWCAaYFrLG+yZgHzJ
         ina0J1o0vTqyLIiO8A0bql9Ij2D9oCtbVEMClE/mOa58/yJRipnWhyBt4iQ/FDb5d6bz
         dzTCX0GPmna9QJmYFBHDkzfKhCo8mB0Cad9ZBr9gt6Vhj9ulzd4svGfZh8ESLHX18zGM
         rSFkyoceykHfLNpASc6Wxwo/8UNgb/KRaOmDw6gKsjE3gz2ZVykw5xgsNJPDRciQdlI5
         D1QQ==
X-Gm-Message-State: AJcUukePpP/lg1bGw4/OHUe+c5sqwecDJb0fDfTNSaVMUyqupvfiRbqy
	O0/LXCAYDxzqH2vSpZbs/YBOni35ZpUVrqOrZG2UinEY5lTe3+GyZgqTulI2sC18KcOvbjuGGQj
	g3Ymdb8z8DGfFoVKoDltSFLstkXz0GrJtW3RHGji/djBPkU/qgii0i4yOJPDGjPyNWumMHgr1Kj
	U4KYEyhFEM2G+kxJooZSovZrIdi5Ldd9tCHr/AsSTNeNWfBVBva7yTXiCEGhaDMpaOH5y7nAmoW
	0aCOxlkF3o1PDeRCCY5OUsmRfmm7kNhsG56gqXsl0f9gxqu05vxp/WyOLGabzJFYaNjL6X5FhoJ
	LOQWPg344Sm2Pot5hjMAjnncecdMT0qFvVt+v7ivbDg46xHDaSJXTrydDzcYdDewghecaLgCf+v
	s
X-Received: by 2002:a62:160d:: with SMTP id 13mr4254640pfw.203.1545430728403;
        Fri, 21 Dec 2018 14:18:48 -0800 (PST)
X-Received: by 2002:a62:160d:: with SMTP id 13mr4254602pfw.203.1545430727658;
        Fri, 21 Dec 2018 14:18:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545430727; cv=none;
        d=google.com; s=arc-20160816;
        b=vzpBcjgFzcIrcYb/AvX+hKqhJRQ2hUSWVcILLjQ85qyjI2kOc0O9Pz1XFeP5yG8Dfb
         2LrRherl8kjpiyPAjzViUg617KcsREZrx49DNnQIQOF47SMZBkafsynPbxRJSlCebNgU
         cfboHs1b3rst/Ig6WHjpYNxsg7Wr2PTMz/ZVAAURNvo9rlc7Ly6pufKnf1P10WDs/61I
         TzL1MruH/YX5l3MIgcaolTDyFrbbV3y0wheNGAdhfyDIdMBoGQXp8aJM8FynjWUq3N31
         EdHFhsvHk/7TFS5YX0f+SnCoxMF3h47pNpbld2TQvnwljorcLf2cx/J5NF7ez5ChG/54
         cgjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=U40y65+ZH6O/HTrNcmmelQb4memE4GhHq1SvommW0g0=;
        b=GdhS9u8kQ6erHRywnialAgx5GYnx7GJ8KHNq8fy6E6rPrnqKz2UuPxyiykH7ALMR06
         9qIg34oB+PeyFWgfKLPjfts3kJQYgV7gnxciuOJc56jhUJHAqmbxG7iYG+VePaZrCIgR
         J2ILJmkS+jHhi01xeLb4gqsbj1mgo0Os1iEENKokSjcj8HVMXJVjAYzXYj8J4Ik4ULf3
         ChjCTTlylBISI/IndFpYYMNX3Kah03DBrX5U0sq60NTawMpCJxOmq/NvmkKDnG7m30mi
         YgufX/fDwIl7nBYqgeOABNqONbKMF3EVkUJ/NpwqqfILFuUueiSjJ7AXPCEStwBNb9TR
         tbOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SnuvSJOm;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n87sor42377912pfh.64.2018.12.21.14.18.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 14:18:47 -0800 (PST)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SnuvSJOm;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=U40y65+ZH6O/HTrNcmmelQb4memE4GhHq1SvommW0g0=;
        b=SnuvSJOme33VXVLmAj3KwMQJ7rP5EsHTXSb7w4ruUQUjCGctfS77aW4uuud4/v5TTz
         HTXZYPMfupfCJ2oezP06V++DM1O3lwwL3HlKSBPwMB3wFA4S5KbpF5A4uX9pe9tzOFzg
         /kUQ8rUJ0zda/5Qj8DY2RtgTTQX2ARcGCSLPhPVCEq+Oo30pFp+yOj4kRwkLTZ5FLf02
         kK6N3FNUnoAJm36zF6OTdD2YShYOK/QeXsP6Xme9zHI+eFtiIrmHXrZk/YfeXJ4JO9ok
         swn8q7xm56TU6iTXeaPvEb0fzU2gENE3uLch1uZ2VcDd6UaVwpYPAM4dYB+r07k0MUQ0
         dFVA==
X-Google-Smtp-Source: AFSGD/UnrwAoCASh7zIOvgMh0kR5aJPKSAJ5y04tNiAjSj9X0kItaQH4nIMGPxe4Zysuq8T9DEZjvw==
X-Received: by 2002:a62:509b:: with SMTP id g27mr4360329pfj.48.1545430727243;
        Fri, 21 Dec 2018 14:18:47 -0800 (PST)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id r76sm37856735pfb.69.2018.12.21.14.18.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Dec 2018 14:18:46 -0800 (PST)
Date: Fri, 21 Dec 2018 14:18:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Vlastimil Babka <vbabka@suse.cz>
cc: Andrea Arcangeli <aarcange@redhat.com>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    mgorman@techsingularity.net, Michal Hocko <mhocko@kernel.org>, 
    ying.huang@intel.com, s.priebe@profihost.ag, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
    alex.williamson@redhat.com, lkp@01.org, kirill@shutemov.name, 
    Andrew Morton <akpm@linux-foundation.org>, zi.yan@cs.rutgers.edu, 
    Linux-MM layout <linux-mm@kvack.org>
Subject: Re: [LKP] [mm] ac5b2c1891: vm-scalability.throughput -61.3%
 regression
In-Reply-To: <0700f5c3-66a8-338a-0ba0-2231cc3bb637@suse.cz>
Message-ID: <alpine.DEB.2.21.1812211416020.219499@chino.kir.corp.google.com>
References: <64a4aec6-3275-a716-8345-f021f6186d9b@suse.cz> <20181204104558.GV23260@techsingularity.net> <20181205204034.GB11899@redhat.com> <CAHk-=whi8Ju-cTDL4cYtwuLA7BYgGJYyy6HVMoknZaLHnRc83g@mail.gmail.com> <20181205233632.GE11899@redhat.com>
 <CAHk-=wguXjkbK8BUU998s7HD7AXJgBkuc9JmuNxiN7uGQyfSfQ@mail.gmail.com> <CAHk-=wjm9V843eg0uesMrxKnCCq7UfWn8VJ+z-cNztb_0fVW6A@mail.gmail.com> <alpine.DEB.2.21.1812061505010.162675@chino.kir.corp.google.com> <CAHk-=wjVuLjZ1Wr52W=hNqh=_8gbzuKA+YpsVb4NBHCJsE6cyA@mail.gmail.com>
 <alpine.DEB.2.21.1812091538310.215735@chino.kir.corp.google.com> <20181210044916.GC24097@redhat.com> <alpine.DEB.2.21.1812111609060.255489@chino.kir.corp.google.com> <0bbf4202-6187-28fb-37b7-da6885b89cce@suse.cz> <alpine.DEB.2.21.1812141244450.186427@chino.kir.corp.google.com>
 <0700f5c3-66a8-338a-0ba0-2231cc3bb637@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181221221845.OGwVRL65ILmmIg5_dnYGUGvRCGLu-HSOFjZp_20-1iw@z>

On Fri, 14 Dec 2018, Vlastimil Babka wrote:

> > It would be interesting to know if anybody has tried using the per-zone 
> > free_area's to determine migration targets and set a bit if it should be 
> > considered a migration source or a migration target.  If all pages for a 
> > pageblock are not on free_areas, they are fully used.
> 
> Repurposing/adding a new pageblock bit was in my mind to help multiple
> compactors not undo each other's work in the scheme where there's no
> free page scanner, but I didn't implement it yet.
> 

It looks like Mel has a series posted that still is implemented with 
linear scans through memory, so I'm happy to move the discussion there; I 
think the goal for compaction with regard to this thread is determining 
whether reclaim in the page allocator would actually be useful and 
targeted reclaim to make memory available for isolate_freepages() could be 
expensive.  I'd hope that we could move in a direction where compaction 
doesn't care where the pageblock is and does the minimal amount of work 
possible to make a high-order page available, not sure if that's possible 
with a linear scan.  I'll take a look at Mel's series though.


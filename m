Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D934AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 17:14:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 893B621900
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 17:14:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 893B621900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 293606B0003; Thu, 21 Mar 2019 13:14:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2439E6B0006; Thu, 21 Mar 2019 13:14:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 158576B0007; Thu, 21 Mar 2019 13:14:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B4C426B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:14:56 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z98so2525090ede.3
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:14:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wvI5mvaMnQli+bNnDnHjaRJoLFtxc+XjGMwchmcGm9s=;
        b=l9iAe/QlfpBSSwLzii6tOHVv7XDiCOfd9XkOy8WxKEVBMtFmUMs+d3/0G8GZ32OHkq
         c3kcf/GBJO3DknJA2KPKcBc+KFpJkR9Pg9NuvNUJZug8t262o9Pd36ONqfhtsVp1v2tl
         zndYOvH0Sr63PuaSPcy6JMR9mx0/3LWb5udqejuMcS6IMQZJJiWglNX49nnUWoM56N/y
         Xp36+KbK43g4W0BppkUcRRB3NsmW6rs3Q+Ec0duM8kCIaewEyKaNffy3g+FsSeMOIlfE
         L7gDbUyhQOwfdXeK1BLg5qDRPisU60eAQHO9nXQ2CdfDcAAUld07/1YYLI6397BrW0rC
         0oSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXj1IzrmzNgs9MWBEmiMLDLXvEHqXCj+uolQ84+R4b6g3/qo2n/
	wgVKH0jl96tRIcFqTY0HC4qqvyIQ4UaH60iEwENRs6V14fv87mm33Npy3XumpOhZfpafPtzcSf8
	abkoezrWAwfL8GH5unY4rSyqldC59JJVxrqVY/OpSOHJVOb6sYMWVuIHbV95/i59uLg==
X-Received: by 2002:a17:906:6792:: with SMTP id q18mr1374124ejp.248.1553188496309;
        Thu, 21 Mar 2019 10:14:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKiOvc5apSJ/YuSz7sRWw6JvJ3DeHqTyvznvTuuHx+F9kfwnH9AW4ebCBy5475QBKWcZxN
X-Received: by 2002:a17:906:6792:: with SMTP id q18mr1374084ejp.248.1553188495213;
        Thu, 21 Mar 2019 10:14:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553188495; cv=none;
        d=google.com; s=arc-20160816;
        b=YDCyhya70KV0EkAVi+6Wy/a2VJqUPeHATiGQao7hZY+uLKHVZbgeMfFUB59Thv1Dq4
         B5KcaSCaHLer8Bh4ZN8Rr/02YrD4TtKZjHL7ZouMKAX5Uwc+D04XCx322ni1Ay4SkDME
         q1bcANJcMpXHqwIksIhplqnsyhGJWs6fNCQtT3Pf3cnvoZJ92aej0/iv5RnEwAL2znLp
         E69lNi1E7Jpczcuos+kRnvxhtcPf8nqCZJxDDXzL6cUG7AUdm5DgMEzi3RvLRgt1SJLG
         gDQbbnHrhVmM4TvvohM6QuFDNuFR4AE+Uu09LaBNC+uJcTqvTMVsElC+rV0TzDsmhVBv
         JLng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wvI5mvaMnQli+bNnDnHjaRJoLFtxc+XjGMwchmcGm9s=;
        b=Ebul1TZtgCilJRGPz7QU/QESxwYa3eaxwKEJI1WXcNY/C1g6F9ylZYGuWk/NMB7pU2
         UHZH9haiiu5l/stvZzJP6Sdg4i/ywJjo+MS2XXI+6BTW9InXkay3DMz2JiXJG6d9Cook
         SsaqFbZZ6YaciUGvbcu8Ha8O2mD0q+wJHDvyHWcQh43XdsoGkOZzuicDgOaTr9cMkrLu
         dFD9vwiH4U+TlzSGviys5Hh73vg8Y1YTmGoV2+Ou9RScUG5iPCPOF7xBIPjjCYwWevgM
         srOQwDI5+4HB+XbgsREA86TxKmd7DYjXuW1WA1TO3vWKb+nzAsfGbBnrDUypMLwCKBMG
         8bCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id b2si2221736edy.385.2019.03.21.10.14.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 10:14:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) client-ip=46.22.139.233;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id B93EA1C2B45
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:14:54 +0000 (GMT)
Received: (qmail 30480 invoked from network); 21 Mar 2019 17:14:54 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 21 Mar 2019 17:14:54 -0000
Date: Thu, 21 Mar 2019 17:14:53 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, daniel.m.jordan@oracle.com,
	mikhail.v.gavrilov@gmail.com, vbabka@suse.cz,
	pasha.tatashin@soleen.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/compaction: abort search if isolation fails
Message-ID: <20190321171453.GE3189@techsingularity.net>
References: <20190320192648.52499-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190320192648.52499-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:26:48PM -0400, Qian Cai wrote:
> Running LTP oom01 in a tight loop or memory stress testing put the
> system in a low-memory situation could triggers random memory
> corruption like page flag corruption below due to in
> fast_isolate_freepages(), if isolation fails, next_search_order() does
> not abort the search immediately could lead to improper accesses.
> 
> UBSAN: Undefined behaviour in ./include/linux/mm.h:1195:50
> index 7 is out of range for type 'zone [5]'
> Call Trace:
>  dump_stack+0x62/0x9a
>  ubsan_epilogue+0xd/0x7f
>  __ubsan_handle_out_of_bounds+0x14d/0x192
>  __isolate_free_page+0x52c/0x600
>  compaction_alloc+0x886/0x25f0
>  unmap_and_move+0x37/0x1e70
>  migrate_pages+0x2ca/0xb20
>  compact_zone+0x19cb/0x3620
>  kcompactd_do_work+0x2df/0x680
>  kcompactd+0x1d8/0x6c0
>  kthread+0x32c/0x3f0
>  ret_from_fork+0x35/0x40
> ------------[ cut here ]------------
> kernel BUG at mm/page_alloc.c:3124!
> invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
> RIP: 0010:__isolate_free_page+0x464/0x600
> RSP: 0000:ffff888b9e1af848 EFLAGS: 00010007
> RAX: 0000000030000000 RBX: ffff888c39fcf0f8 RCX: 0000000000000000
> RDX: 1ffff111873f9e25 RSI: 0000000000000004 RDI: ffffed1173c35ef6
> RBP: ffff888b9e1af898 R08: fffffbfff4fc2461 R09: fffffbfff4fc2460
> R10: fffffbfff4fc2460 R11: ffffffffa7e12303 R12: 0000000000000008
> R13: dffffc0000000000 R14: 0000000000000000 R15: 0000000000000007
> FS:  0000000000000000(0000) GS:ffff888ba8e80000(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007fc7abc00000 CR3: 0000000752416004 CR4: 00000000001606a0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  compaction_alloc+0x886/0x25f0
>  unmap_and_move+0x37/0x1e70
>  migrate_pages+0x2ca/0xb20
>  compact_zone+0x19cb/0x3620
>  kcompactd_do_work+0x2df/0x680
>  kcompactd+0x1d8/0x6c0
>  kthread+0x32c/0x3f0
>  ret_from_fork+0x35/0x40
> 
> Fixes: dbe2d4e4f12e ("mm, compaction: round-robin the order while searching the free lists for a target")
> Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs


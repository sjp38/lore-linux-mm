Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D94CC43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 15:22:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 348592087F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 15:22:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 348592087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CCC36B02EC; Sun, 17 Mar 2019 11:22:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87B8C6B02EE; Sun, 17 Mar 2019 11:22:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 769D26B02EF; Sun, 17 Mar 2019 11:22:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8A56B02EC
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 11:22:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f15so5887449edt.7
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 08:22:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3cM0zmrXFBuzTxzWuBI9QCBN4h+DSbMmwUA/oQgTbtg=;
        b=e61190+gXgAUHBel8gNScl6t9KV1AlVe+/P+dYTE+j1Wv8/CpL06sTBIsZ1LpnJmXY
         WKPyxkRA0QT6vZSoeVDd+ZDursu5GJe/j9UNVXOyIbV1qeG6jOdIoFZWggEzctB3fxLN
         vZD4b+x1UKAhJUg3/bEQraLfejDwTpNHl9jItPCGGoCnc5NSBGH6901VhNqUAzapd86q
         CnpA9GkBMlzhWCigoU03HwwGBy/WbFAO0xBwd/On2T0qu+tNkqd4kWZXeKbA16zrYh+P
         TJ1yd2rXzjYfQ/149hDOB2lgAX6H62qOqCbsPfLR480/P+QZjqOsopKx7xA0T3KkN+F2
         L/NQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.230 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXoH3+AdgXSmiTw8hIyhAD9tQcXJmx+vcTNxHcVG9/4NN5SYel8
	xA9STXvUKO8l7JrSb5liE4ARWqQeeHqsgLyQCqWPBoYHVqQUQ39G9iz9Ooz4QNHs56gZVbyR9Jd
	evxW+JTMmS+O7uWyKX+goXspAho+J980dI93zM9yswtsz9Wuh7axcXJXDa5VGGAfKrg==
X-Received: by 2002:a50:b3ad:: with SMTP id s42mr9937428edd.142.1552836127566;
        Sun, 17 Mar 2019 08:22:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNpIYhms2AP48MVQn5jH4Ssxpgk9h0OG69ECZewdo0+9FnQhf3oRaiWyCl+2mWnhvRExPP
X-Received: by 2002:a50:b3ad:: with SMTP id s42mr9937397edd.142.1552836126616;
        Sun, 17 Mar 2019 08:22:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552836126; cv=none;
        d=google.com; s=arc-20160816;
        b=jl6Be/D+GNPXWGHGEH1DkSV9peXQKEuvrjzyWJlqzEPh5sMMeHFM0WAT6rwC6HR4wO
         4jbIptzvqzZjKI+SHUifx7oBtf6flDJ6QN7SOMIfNwJkjRw1dyeQ6+/KllZSQRV0RsIh
         ozDi0CVuPpPMM4w+4lD5n9riQgaw423HQLlJjo0J8czYLNNYfQ6D9X+o+s2HFYi9JmgS
         aKoF64+0q32rLX8Hgt3Vj9iIIXG/PfHfYhVTKGIw6XjLvSud1v/bjbedEM0vQaMb82HM
         0AFnah3CDZw8Ig2f4ImKApiBfoJSTdmAYhpZiBnHhF2G6xkkmEFuc2IMvnXpEwMcfFO7
         7z4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3cM0zmrXFBuzTxzWuBI9QCBN4h+DSbMmwUA/oQgTbtg=;
        b=ZFnk87ShmPT1i7s1H4fF++ibDBEulyCbHWXw+6jg3y9z9BIkSUPgfIuqYBRF+d3zve
         B0nz5WZc1KHBCxQ8lah5BF061N86uvS6XNtWiMPMClkqtg/UWV2PILAHQhPNnUKneKKl
         Y0hNt+FAGzmQgpZt9ztzYOwtExAJG66PWlpxV0DUo136ZNg+6fnq0EY/kiApkAw27Uf7
         HxNMtCdZNqlKewi/gs7dvQJq4kdFjT1eJgwur2EJ4AqD1C/BAvZWElMYBkEfrAy3brmH
         mcaF6b3UYwqoLKu9z1hZH6YonItYj+gvxkKN3kJ5l8/ZiNw4WfPjx5o0pnFZ2HgNxTCq
         cHWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.230 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id i7si1843797edg.251.2019.03.17.08.22.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 08:22:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.230 as permitted sender) client-ip=46.22.139.230;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.230 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.17])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 273591C2519
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 15:22:06 +0000 (GMT)
Received: (qmail 24889 invoked from network); 17 Mar 2019 15:22:06 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 17 Mar 2019 15:22:06 -0000
Date: Sun, 17 Mar 2019 15:22:04 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, linux-mm@kvack.org,
	cai@lca.pw, vbabka@suse.cz
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190317152204.GD3189@techsingularity.net>
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 04:58:27PM -0400, Daniel Jordan wrote:
> On Tue, Mar 12, 2019 at 10:55:27PM +0500, Mikhail Gavrilov wrote:
> > Hi folks.
> > I am observed kernel panic after updated to git commit 610cd4eadec4.
> > I am did not make git bisect because this crashes occurs spontaneously
> > and I not have exactly instruction how reproduce it.
> > 
> > Hope backtrace below could help understand how fix it:
> > 
> > page:ffffef46607ce000 is uninitialized and poisoned
> > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > ------------[ cut here ]------------
> > kernel BUG at include/linux/mm.h:1020!
> > invalid opcode: 0000 [#1] SMP NOPTI
> > CPU: 1 PID: 118 Comm: kswapd0 Tainted: G         C
> > 5.1.0-0.rc0.git4.1.fc31.x86_64 #1
> > Hardware name: System manufacturer System Product Name/ROG STRIX
> > X470-I GAMING, BIOS 1201 12/07/2018
> > RIP: 0010:__reset_isolation_pfn+0x244/0x2b0
> 
> This is new code, from e332f741a8dd1 ("mm, compaction: be selective about what
> pageblocks to clear skip hints"), so I added some folks.
> 

I'm travelling at the moment and only online intermittently but I think
it's worth noting that the check being tripped is during a call to
page_zone() that also happened before the patch was merged too. I don't
think it's a new check as such. I haven't been able to isolate a source
of corruption in the series yet and suspected in at least one case that
there is another source of corruption that is causing unrelated
subsystems to trip over.

-- 
Mel Gorman
SUSE Labs


Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A128FC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 13:30:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45AFE222AA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 13:30:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45AFE222AA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C17646B0003; Fri, 19 Apr 2019 09:30:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA0216B0006; Fri, 19 Apr 2019 09:30:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADCC46B0007; Fri, 19 Apr 2019 09:30:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 61B726B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 09:30:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id u16so2849793edq.18
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 06:30:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=a5Om8ovCuIz9VaJEUD70FklSFAGjVjefKwS8QomanNU=;
        b=OTSSMlqj1sMZleMu6eIRGD6vr/Sm53dE9ZGDqZPxPHGb/K6eJTbgcGZfD857O0rBWA
         7anpQK38IhZEuhTdsuHWI3J10+pINjwJEePsqbaN8pIJ6TpfoL6IoQXiGlrzil+50VDY
         Lc1iV3Ppjjb5H0EXCEwxcwkDAZr4B9CGeOLI6S45b4How19Rv48bCChCR2lrv9KAfHd6
         3T6kzPYtx9xnckvoeMH2E2X9nH+whip9XcUGSQHTUJ35+bb5yamPrx5DOvgYNnjjOqmw
         n+MkqxE2LvBh3/5tp+/Bi0VFvyrLAnk21XFpVkkTcu/DRIioNjZGHspgCmzvXdfih8zr
         7kyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.14 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVNCb18k7KoMUWlWrcLzc7ixhkwe2kngc4g+EEZn50B0dIQZXtP
	HAzTjnzXyahx3lxHSH0sNBexbhbY0KgOA+yUgFZI0VxckhDqrwAR8xEzLkMR36j189tMLhGl4X7
	Ol5tj91gOOtEfoIuiv3jQs93XIsbzwBEmAAuG5ORH5ITuANIYhosS5IM+zu3f7u2cag==
X-Received: by 2002:a17:906:6c0d:: with SMTP id j13mr1917020ejr.249.1555680602942;
        Fri, 19 Apr 2019 06:30:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzU3SSdhPIjezbdQa9bC+HMAhjf2jy650JpUuTjTx7+IQmoLezIBVHo/fRn0OtQxVgHwodV
X-Received: by 2002:a17:906:6c0d:: with SMTP id j13mr1916994ejr.249.1555680602029;
        Fri, 19 Apr 2019 06:30:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555680602; cv=none;
        d=google.com; s=arc-20160816;
        b=IConTIrhfUT/ORBzE2IPz6gehktQDoMNqeE6jZpXIDOqElRm/fgh3jWp5d/yVRCTW0
         3CghGZJNdMlRJktlYoZrbljLtrD+ycrHEMXOykjqoD8ooZIzwPIFH8umasCrHD0qtw/E
         maBkCrEPdL+joQ8Unfy6kChArWQOno+173hVwWZOIvLXz0ec+4PesYC3de5iaX6m3IXt
         GRzK9nuP+MqU751WrvjQ6tNLNZBJjRrNt9TXENnkT++jMwfMKAn3JrWajKwIrtz+KdHS
         gJ5DPMsHWT2alLjEMbd1BYWqlZPWQX3sG+G/zXgXhx7YJV3RSmGwyF0P6Mf3FKH5FaHe
         DqHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=a5Om8ovCuIz9VaJEUD70FklSFAGjVjefKwS8QomanNU=;
        b=Ub3uHV94neW0k5cJi4/IHXRyyykpu8/giYbLR2JYOFfrsdZGoCXenOTT3oFcWY8Nim
         uAe+3+zQ0PEi12E3RjD033GbxQkENAhbq82n5Jwx50o1zwwolWKSUulG54hQv/bLQpet
         0XobKt+rcccd0ZD3+OCbL9jeuPUOxqFMWhr/WaT0Bt5513b67ruTUaMg2eydosbGbC/v
         KzLmqslTOBXnLYeMkcCs7WCNLBurP/kSRq/NPur8yWfZN4rGZeHZ6Fon1v45qfXYHeT9
         n8dgo8td3wxE9Frbs5ECO9fs4jp3w+MDOy7UqaiYUC667rk1g3ZzP8xxSddf5Rm6NOj6
         mQeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.14 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id y8si2255028edv.7.2019.04.19.06.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 06:30:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.14 as permitted sender) client-ip=46.22.139.14;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.14 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 809DE1C318F
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 14:30:01 +0100 (IST)
Received: (qmail 29446 invoked from network); 19 Apr 2019 13:30:01 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 19 Apr 2019 13:30:01 -0000
Date: Fri, 19 Apr 2019 14:30:00 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Li Wang <liwang@redhat.com>,
	linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm, page_alloc: Always use a captured page regardless of
 compaction result
Message-ID: <20190419133000.GL18914@techsingularity.net>
References: <20190419085133.GH18914@techsingularity.net>
 <e99a54aa-bc21-d3f3-54a5-5da0039216a9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e99a54aa-bc21-d3f3-54a5-5da0039216a9@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 02:54:54PM +0200, Vlastimil Babka wrote:
> On 4/19/19 10:51 AM, Mel Gorman wrote:
> > During the development of commit 5e1f0f098b46 ("mm, compaction: capture
> > a page under direct compaction"), a paranoid check was added to ensure
> > that if a captured page was available after compaction that it was
> > consistent with the final state of compaction. The intent was to catch
> > serious programming bugs such as using a stale page pointer and causing
> > corruption problems.
> > 
> > However, it is possible to get a captured page even if compaction was
> > unsuccessful if an interrupt triggered and happened to free pages in
> > interrupt context that got merged into a suitable high-order page. It's
> > highly unlikely but Li Wang did report the following warning on s390
> > occuring when testing OOM handling. Note that the warning is slightly
> > edited for clarity.
> > 
> > [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_direct_compact+0x182/0x190
> > [ 1422.124065] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver
> >  nfs lockd grace fscache sunrpc pkey ghash_s390 prng xts aes_s390 des_s390
> >  des_generic sha512_s390 zcrypt_cex4 zcrypt vmur binfmt_misc ip_tables xfs
> >  libcrc32c dasd_fba_mod qeth_l2 dasd_eckd_mod dasd_mod qeth qdio lcs ctcm
> >  ccwgroup fsm dm_mirror dm_region_hash dm_log dm_mod
> > [ 1422.124086] CPU: 0 PID: 9783 Comm: copy.sh Kdump: loaded Not tainted 5.1.0-rc 5 #1
> > 
> > This patch simply removes the check entirely instead of trying to be
> > clever about pages freed from interrupt context. If a serious programming
> > error was introduced, it is highly likely to be caught by prep_new_page()
> > instead.
> > 
> > Fixes: 5e1f0f098b46 ("mm, compaction: capture a page under direct compaction")
> > Reported-by: Li Wang <liwang@redhat.com>
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Ah, noticed the new formal resend only after replying to the first one,
> so here goes again:
> 
> Yup, no need for a Cc: stable on a very rare WARN_ON_ONCE. So the AI
> will pick it anyway...
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

With luck, this will be picked up and sent to Linus before 5.1 releases
and then the stable bot will not need to touch the commit at all.

-- 
Mel Gorman
SUSE Labs


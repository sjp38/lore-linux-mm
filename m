Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74F01C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:24:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3173B20880
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:24:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3173B20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC4518E0003; Tue, 29 Jan 2019 15:24:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D73368E0001; Tue, 29 Jan 2019 15:24:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65B68E0003; Tue, 29 Jan 2019 15:24:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7DB8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:24:44 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t7so8387859edr.21
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:24:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AqxO8IwKAG+CaGTTOIHDlBdneEiO5EciQE4lrGbpXL0=;
        b=cnwQASgJlG0GIKK5viQP2+v9TdvATVzEdkVVpZ8/JYzS0JuPVaI/RSOiJMkNhFBSIA
         fOxdH6Y7rkZEdC6CjUbEaAA673c/OrDkTyQCmMxxPaTA3Vn447FGLLnyXMdQTY3QGFEf
         i6VAVPnzr1GkIGSu5srgoVpxIwSUZka9I9G5FNT2/9jR45iq6sPhbccAgjZKDaWArhyw
         orazq1WL/LpK4r8c6gEIPHkCUAKX2lNoARB39LR01sOrJU1KnsKf+FN0ycVYKXOi3Vjn
         nGNBoYLmPNNl30JoK8nmzGuWbR7j+L5Yi3U1zttCe/+dd6KZVaMtzInDmXYuDcqIbLm6
         Q+rQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukf3KBxBa/bZSqMo7MZY5Pkpdurn2SmydbJLfrlIUDoL8EZ8iYjU
	STOlk910vG+SE/OA8X0OicDUfnezdsJhSagFp3yLb4t0Ue9t+Joq7cevwfIsg2Ua+AGVwWJWTqR
	izkIcFvPMdAbcwqkxIj4Mv5tuVfk232GuPv+cub0NtMnSiodBid0r6eVQ1XY/SYk=
X-Received: by 2002:a17:906:9259:: with SMTP id c25mr8295609ejx.31.1548793483961;
        Tue, 29 Jan 2019 12:24:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaY0XyVukkt0ovg9uEFUTce/UCqvMmFhtbYKoeF+xhJG+iLyklKBfZo6niNMY2gwbBnxi6n
X-Received: by 2002:a17:906:9259:: with SMTP id c25mr8295566ejx.31.1548793482953;
        Tue, 29 Jan 2019 12:24:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548793482; cv=none;
        d=google.com; s=arc-20160816;
        b=tczigVeFYQ452KqZJMajq6yu+MZDXCUnUHTy+3AjfjThTScXha2AdbPctgdhLQdLVs
         NtJYokXrIHs8OPVDZaKg3JgnM2atPBR5yArzDj9gUdmq98jpk241QCz53kFCEfXeXQA3
         8wC0+w6d/Is8pU78gxnn1wDjQVwbc1+PXT0nRReRnbgD3cLn04Gv1FaCVWocg9EfTKPT
         RCCc3eCDp24pLUP637+R7aurRfO3BhQ7iGBwWx74+ijFXgPEvqEVNFR3t516nci1JiXG
         AJwGLtCN8alNalMx3QfgAe4I5WLPHYI9tsG0u5sMcORTqGa2uI5xWs3OHsoNjicZECcW
         E/fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AqxO8IwKAG+CaGTTOIHDlBdneEiO5EciQE4lrGbpXL0=;
        b=knrKYZYk2DNSRG5VW/Keb1ErrW++fCAQtMBJcXYnGO14Ada/QXYYdiLosYJEfIrp87
         VDi0hXuugdcqO705U01hj6YPHV/uEJqW1udZoYr3W7bZ7RxwvfZKlhpIZANdgYZRN8/X
         sYmu1JY5bAkk7kvA6eks0koq7m45ugQN7evl384EULhOHRIc/d2V1tAJFlzY2NDe9Mk/
         WSnxQ3RCwom64jV2BaFLWAoUj75/Od5cnWbL+cWg6D0YiZGgWrWC7KvDada9xmrF9TYG
         8NxyCr2HqjJuuZGS/oXuHdmrnKQu5/HI4pd7qGW50f+f7t0719INJzgENCcqyqBsvhLH
         eWTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y9si897885ejr.173.2019.01.29.12.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 12:24:42 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 60854AA71;
	Tue, 29 Jan 2019 20:24:42 +0000 (UTC)
Date: Tue, 29 Jan 2019 21:24:40 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages fallouts.
Message-ID: <20190129202440.GP18811@dhcp22.suse.cz>
References: <20190128144506.15603-1-mhocko@kernel.org>
 <20190129141447.34aa9d0c@thinkpad>
 <20190129134920.GM18811@dhcp22.suse.cz>
 <CABXGCsPM-JrdxN9t-HjkWxJJzdGHiJZOYD5p-CsjGEFSQ=+DwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsPM-JrdxN9t-HjkWxJJzdGHiJZOYD5p-CsjGEFSQ=+DwQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 29-01-19 22:38:19, Mikhail Gavrilov wrote:
> On Tue, 29 Jan 2019 at 18:49, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 29-01-19 14:14:47, Gerald Schaefer wrote:
> > > On Mon, 28 Jan 2019 15:45:04 +0100
> > > Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > > Hi,
> > > > Mikhail has posted fixes for the two bugs quite some time ago [1]. I
> > > > have pushed back on those fixes because I believed that it is much
> > > > better to plug the problem at the initialization time rather than play
> > > > whack-a-mole all over the hotplug code and find all the places which
> > > > expect the full memory section to be initialized. We have ended up with
> > > > 2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
> > > > memory section") merged and cause a regression [2][3]. The reason is
> > > > that there might be memory layouts when two NUMA nodes share the same
> > > > memory section so the merged fix is simply incorrect.
> > > >
> > > > In order to plug this hole we really have to be zone range aware in
> > > > those handlers. I have split up the original patch into two. One is
> > > > unchanged (patch 2) and I took a different approach for `removable'
> > > > crash. It would be great if Mikhail could test it still works for his
> > > > memory layout.
> > > >
> > > > [1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
> > > > [2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
> > > > [3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz
> > >
> > > I verified that both patches fix the issues we had with valid_zones
> > > (with mem=2050M) and removable (with mem=3075M).
> > >
> > > However, the call trace in the description of your patch 1 is wrong.
> > > You basically have the same call trace for test_pages_in_a_zone in
> > > both patches. The "removable" patch should have the call trace for
> > > is_mem_section_removable from Mikhails original patches:
> >
> > Thanks for testing. Can I use you Tested-by?
> >
> > >  CONFIG_DEBUG_VM_PGFLAGS=y
> > >  kernel parameter mem=3075M
> > >  --------------------------
> > >  page:000003d08300c000 is uninitialized and poisoned
> > >  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > >  Call Trace:
> > >  ([<000000000038596c>] is_mem_section_removable+0xb4/0x190)
> > >   [<00000000008f12fa>] show_mem_removable+0x9a/0xd8
> > >   [<00000000008cf9c4>] dev_attr_show+0x34/0x70
> > >   [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
> > >   [<00000000003e4194>] seq_read+0x204/0x480
> > >   [<00000000003b53ea>] __vfs_read+0x32/0x178
> > >   [<00000000003b55b2>] vfs_read+0x82/0x138
> > >   [<00000000003b5be2>] ksys_read+0x5a/0xb0
> > >   [<0000000000b86ba0>] system_call+0xdc/0x2d8
> > >  Last Breaking-Event-Address:
> > >   [<000000000038596c>] is_mem_section_removable+0xb4/0x190
> > >  Kernel panic - not syncing: Fatal exception: panic_on_oops
> >
> > Yeah, this is c&p mistake on my end. I will use this trace instead.
> > Thanks for spotting.
> 
> 
> Michal, I am late?

I do not think so. I plan to repost tomorrow with the updated changelog
and gathered review and tested-by tags. Can I assume yours as well?

> I am also tested these patches and can confirm that issue fixed again
> with new approach.
> I also attach two dmesg first when issue was reproduced and second
> with applied patch (problem not reproduced).

Thanks!
-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B10FC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:30:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0654420882
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:30:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0654420882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 946A78E0002; Wed, 30 Jan 2019 07:30:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CC738E0001; Wed, 30 Jan 2019 07:30:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 794508E0002; Wed, 30 Jan 2019 07:30:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31C008E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:30:00 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id m3so19640948pfj.14
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:30:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=HjOIkex/yptwObGw9gC15zXB/6XsITCfD1A4Zl+rt8s=;
        b=TaIJ1TVpnpJHPxU7MWNyk1//rxjrn3e25NyHx0OXaW8iuGJScpH1oi8SxzOn8DxOTc
         QPTWn8yg6vr/MqDhiLvP1Bgg8LvukVzeGHsUqq3c0FOeOMeVIGBL7LpftdXwZKnjdkby
         RE9RWMPHEN2LzhP4lIdr7qaOolvG7h7WXaq+qeVSlV+md966X3+JInyub1kUiwQRXvbt
         MiIptGkw9EWz+CKqxV6e4iShxW64dlyeDbIYhs8mvBxxmX0G9rOJfJv7ZG8V8Jel9a9s
         7369alTERDlN/Dwgwogyn0mxht2dJft1olmlOiLReDD2I4EncUK2n/fak0GXX8X7Js7Q
         UMBw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcchU2MXGvzE8+DheCyHC/sFsmUw99yOetRl8eusM0+rQ7hlDrO
	dOqx7pTwTqvPEgxBFSsY2ueEgF0mDTDMSqnXHJWZxOxKmoALX8Lt6mIq6ckUnlFbfEvp15fqd0C
	IxGB5M2KeEuyfGQSKyf5dNtlA/WmgibZg11E5LQrOkGRXJZsVfovcAOEiBPCGWqo=
X-Received: by 2002:a63:4456:: with SMTP id t22mr28041381pgk.0.1548851399844;
        Wed, 30 Jan 2019 04:29:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7dJ1KPx2+yEgv04AzR5l8RYME4FAiKwHuawGpVSYh+g649iT06YxlDHELw0996Utl2CCSh
X-Received: by 2002:a63:4456:: with SMTP id t22mr28041342pgk.0.1548851399174;
        Wed, 30 Jan 2019 04:29:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548851399; cv=none;
        d=google.com; s=arc-20160816;
        b=AQJ6THRDkIwalTf0ICc8TbzubhU1K1xPMQUgG5zVBeZdGOLeMuR7TSKlBPeelxDXLu
         Lag0zcwdTxsZwkgYIvV0l0+4SkRtvttfpZiX8MoGayPuNJ913GVy699/Y10nd+VGRnoP
         WNonePjL1T+TkurmV2KpSrW8sNr5Pa3Ij/RI4X0W+byaGLqhWdHYoBnpXqlgIj60Y9zb
         as4sBEK5h+F3TLMJByQMA2CuWf70/pp+wfJLfxFq0Fw8cg+DrYJ50BLZwIr3KTjX38/4
         rtDnjAv2zNB+TVXn+usHohlwaT5m+8Kh0GcfxifQeWknFcm1It7HBnwj46f9RT26zKSu
         pblQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=HjOIkex/yptwObGw9gC15zXB/6XsITCfD1A4Zl+rt8s=;
        b=Y6GcgIVbxyxP5FEDNJdlnpYt1TaQlfAHyPhvQqu/qAAOP48PbBm3x9WMSKeXJludu7
         KBnvbwRx5tUMV285UCB7W40Mjg2Y7TBLouyLKRUos+AZagzrcDSVTOoWjV1e9+OetmWZ
         ZqLXnfdA18/O8Mv8cLulGqTaR6BTrUYe4NgMxkXsQIkPePQcNpqb6BAmUbdsOXmBZW7m
         pEDoy9RyB2NnifArz/pnI3TNN4emwOJ71i+An19UFsEu1if25dEli/x2A0Ip+zcHU1nb
         cITo9VQprYyZBGJZoD7803gkH438s98WI4b+uU96qBzmXTZ2gz0PbeZZIO6hsW+SMzg3
         b6RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u2si1286994pgo.544.2019.01.30.04.29.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 04:29:59 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 71FFDAE04;
	Wed, 30 Jan 2019 12:29:57 +0000 (UTC)
Date: Wed, 30 Jan 2019 13:29:55 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
cc: Dominique Martinet <asmadeus@codewreck.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, 
    Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, 
    Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Linux-MM <linux-mm@kvack.org>, 
    kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190130090945.GS18811@dhcp22.suse.cz>
Message-ID: <nycvar.YFH.7.76.1901301328560.6626@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com> <20190124002455.GA23181@nautica> <20190124124501.GA18012@nautica> <nycvar.YFH.7.76.1901241523500.6626@cbobk.fhfr.pm>
 <nycvar.YFH.7.76.1901272335040.6626@cbobk.fhfr.pm> <20190128000547.GA25155@nautica> <nycvar.YFH.7.76.1901300050550.6626@cbobk.fhfr.pm> <20190130090945.GS18811@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2019, Michal Hocko wrote:

> > > I'm not sure why I'm the main recipient of that mail but answering 
> > > because I am -- let's get these patches in through the regular -mm 
> > > tree though
> > 
> > *prod to mm maintainers* (at least for an opinion)
> 
> Could you repost those patches please? The thread is long and it is not
> really clear what is the most up-to-date state of patches (at least to
> me).

Vlastimil seems to have one extra patch to go on top, so we agreed that 
he'll be sending that as a complete self-contained series (either as a 
followup to the very first e-mail in this monsterthread, or completely 
separately) shortly.

Thanks,

-- 
Jiri Kosina
SUSE Labs


Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9817C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:01:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E6EC20823
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:01:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E6EC20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D0078E0003; Tue, 12 Feb 2019 09:01:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47E828E0001; Tue, 12 Feb 2019 09:01:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 347FE8E0003; Tue, 12 Feb 2019 09:01:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CFE128E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:01:18 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m25so2371652edp.22
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:01:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lfuceC7Qr6MbregAzNnIpzF3SVe0mqgXIeSgihQvyNY=;
        b=DoLcdBurmiyIweuZe4Ah6JEkmtN7XSPt4861h/PSnPO620D5VgtgtL4EGKIhRN43Vy
         Zc/xZC74DT5tr4znLQZQNNXp99rH08Dmasn1/oHszBxcdROrneokoJA8oh0ZePgnKVFC
         TXnPMHZiwR/cjUscIFlIP1MR6ZDEcTt4OECLl2seKusnTNmD4QvdPa2lo0Mjo1TeIGRV
         U4+DdA842t5fa5fSFe2PJ+SWfMIart8lcAZGPb7LAL0HBbjoJcWJ2xwyy1YJP8w66SBq
         Vh0TpsWoeCgL4wiKlf7XEzrCip4lVmlsXlm62nXe113gOXrFUPB8+D9qjj6S1X1l5HA9
         7dgg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaOK43kLOWvx4AsZwzbPm2JVP4N4sWtN1PMhKgPj0RjV4g5coPs
	nPHhuOqNsCHJlVM7OGm5byJppNhiBzjdpzgHVFZ//Y1zUrPJBzADq6CytIF3MofFFRwkMaOjxVJ
	fL2zAmtmoXMhhmxis/3V/eUlJljAEMxxzQDtqDU5GYiicqSAiqnW+5U0y6OjW+DU=
X-Received: by 2002:a50:9908:: with SMTP id k8mr3084233edb.246.1549980078397;
        Tue, 12 Feb 2019 06:01:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib4UdsMBOpQ10O3og+7nELHe73JSqW8AjcajWkU0t01dmrV9oJ/soWVzvYVwoifMO2eFMly
X-Received: by 2002:a50:9908:: with SMTP id k8mr3084163edb.246.1549980077225;
        Tue, 12 Feb 2019 06:01:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549980077; cv=none;
        d=google.com; s=arc-20160816;
        b=sWDdRIsGa9vACn4/E52bLe+rDQ8QozWOg3eYNBu7txU0QhAf9BD12+0pYCzIcOtaSv
         2LjAkqs/UeEN735HQzgFtpauZ5Y8/Plgai0a1Vhcr14ZmFdYLi1pSj9y1p4vbKzMEUTb
         X+qcKIp9wwurrIsgQiLcP5eu6G0m3OrCvznNQZk39w4KtnVSr5yst9/DXtWiZnm9nVtK
         8wFDiHCvfqMmSvFTw2gm9EGtiP+5lTkUDV6AxlytffOrT3J+32t055reSkTh5YLpc+wx
         smvt3lIy7CCuk6kGBRymcKlowcuelmxeGRb80oO/2pV2b8Vu8A9faJfxbhbF/gOJJuZ5
         2Dew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lfuceC7Qr6MbregAzNnIpzF3SVe0mqgXIeSgihQvyNY=;
        b=VnbP31ZOhS9TfizOFf7aMWNKoYPjFGq/CdgEkDfv9aAhbl0h5O/tEvZN29FMZPxKf/
         lTOcmU9I1N32rgE5S9NgOME0NV6bo/Xc+whmDeNF/+Sj757S7MUs6tY/OvE/BG82QyUO
         sp+Dm9mHmR2RGVKi/R6GQ9l4RNw1TrXMGqoTVLK5kDWSJeh4PMUuL1UpnzMFaTwVGDpZ
         SP+Pga4ogo5THntphI6p7xCqvqhL+13xZAeDLkj2QMGH6NDfC3jH/k8cLp0siF0++C05
         q31fAUYZe8mZneo8dtrjuqaYwItwha1v6FAiFXC530w1GnuUZBfXkVxpqvHFshPSiN0v
         nulw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si1729867edp.248.2019.02.12.06.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 06:01:17 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 62C4AAEFF;
	Tue, 12 Feb 2019 14:01:16 +0000 (UTC)
Date: Tue, 12 Feb 2019 15:01:14 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>, Josh Snyder <joshs@netflix.com>
Subject: Re: [PATCH 3/3] mm/mincore: provide mapped status when cached status
 is not allowed
Message-ID: <20190212140114.GX15609@dhcp22.suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-4-vbabka@suse.cz>
 <20190131100907.GS18811@dhcp22.suse.cz>
 <99ee4d3e-aeb2-0104-22be-b028938e7f88@suse.cz>
 <nycvar.YFH.7.76.1902120440430.11598@cbobk.fhfr.pm>
 <20190212063643.GL15609@dhcp22.suse.cz>
 <nycvar.YFH.7.76.1902121405440.11598@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1902121405440.11598@cbobk.fhfr.pm>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 14:09:03, Jiri Kosina wrote:
> On Tue, 12 Feb 2019, Michal Hocko wrote:
> 
> > I would go with patch 1 for 5.1. Patches 2 still sounds controversial or
> > incomplete to me. 
> 
> Is it because of the disagreement what 'non-blocking' really means, or do 
> you see something else missing?

Not only. See the remark from Dave [1] that the patch in its current
form seems to be incomplete. Also FS people were not involved
properly to evaluate all the potential fallouts. Even if the only way
forward is to "cripple" IOCB_NOWAIT then the documentation should go
along with the change rather than suprise people much later when the
system behaves unexpectedly. So I _think_ this patch is not really ready
yet.

Also I haven't heard any discussion whether we can reduce the effect of
the change in a similar way we do for mincore.

> Merging patch just patch 1 withouth patch 2 is probably sort of useless 
> excercise, unfortunately.

Why would that be the case. We know that mincore is the simplest way
_right now_. Closing it makes sense on its own.

[1] http://lkml.kernel.org/r/20190201014446.GU6173@dastard
-- 
Michal Hocko
SUSE Labs


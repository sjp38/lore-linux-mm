Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7EE4C43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 13:19:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E1EE206B6
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 13:19:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="r4cOdXHt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E1EE206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1C288E0079; Tue,  8 Jan 2019 08:19:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC8EA8E0038; Tue,  8 Jan 2019 08:19:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB9BD8E0079; Tue,  8 Jan 2019 08:19:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF3668E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 08:19:10 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w1so3298727qta.12
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 05:19:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=i/LKjvpf6BLPa3asEup3mQ52HQP7Vz8QBeRkG2BpFpY=;
        b=q8yfI9KIoKH6WVF4B2ReYssXtn0U0SdFHnsqm9ki1yK3CMk/Xj2TdNWfXHkiHgPbfW
         mxV1lqwGmLXUD/jS0nYEKzulT0m7hd1sjWPwUdy4uNkvMmNaDoBKLWNB9qeW4v6NSWb0
         LBXF0TSuLxReIDm7c8SQOmn30MKKUoLyPVvtf8WyIbwLnEujua2nzpwaoGixu1vAr37R
         GYYI7VYtfbsdU1apvlCeWzXKMZzgy9K+1oSMqDcjXVQcjQxNn0z3EhhcFMai0mO8jzkP
         VBOk3uaTCoMQ3s5WXnUxxMqa+iz5wHOLeSCpoYSX19WxJIXNv02vYg7IT3ikB71E/ADJ
         RDtg==
X-Gm-Message-State: AJcUukcldDrC5H7YtNjMSZCIUjpGwe/xEqOUJs2Fkdo61zDbJZVQvdVV
	0FZ3azmrGhNqX9bLqaCDO8Jty802wDx3DSNiRIrxDBRVEFeFHf8MyqYODNVYf4Fld4XPitM/WSS
	FSFmErulieHjDSqQElNfdemfUh7DuTJHzwPdE1+wU6AjqxhLrnOFDRP+9NOujbvIDp3YIzXbOVQ
	0tkqDSnfu7VxJWmGsTQJHlZXIg1TKFBNIzPm18w4hpgaDXoMSnF2g62cHEOvVK4m9H6jUqjPYhz
	AMmZo8q0Ccf6NxZ3la4xgWkKD5VluduLPl2WEcQ5Gz8YJRx77fEPhR6nqX4OiwInXW9p1NE2UB1
	cK6r1OtsYJXOS7q/FqVIKejn8sTngDFs56tgPV6iAkQ5E42v29+vjfbQRyLr0QfjnUmjOX+jnsq
	h
X-Received: by 2002:ac8:2fdc:: with SMTP id m28mr1652577qta.202.1546953550454;
        Tue, 08 Jan 2019 05:19:10 -0800 (PST)
X-Received: by 2002:ac8:2fdc:: with SMTP id m28mr1652517qta.202.1546953549669;
        Tue, 08 Jan 2019 05:19:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546953549; cv=none;
        d=google.com; s=arc-20160816;
        b=Ba6tQ1u5YW4PVRLfujq6iV5mQMvMLU4VS0zraDzk0u83R9QkWbV0HPldkqVLi5b+TX
         QxdrIe/nIqNhBlaZTxG8Omy6jmLE/bR9Q7N5btK/gIuYGmikzgXi/DIO+6S+uIgie3ex
         zjCqooFxgvIyr8zprlqUreOY2zaFwJK4/QR0fchwuRQFlSzZpQ9qJL2vdKnOOpA+r9um
         hACwP927Y1hExkNq1Qg+aAZ/zs4tjJ3fL8SkWqsEXtsaQ8xYSa1pw6z7SzWDXKO56/b0
         HhQe9JkkmKg+felflvXxha4fWfjY8TRd77VAKi6vME5uRhd0O5uS7eqwvVwzVLv3f9jj
         Brpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=i/LKjvpf6BLPa3asEup3mQ52HQP7Vz8QBeRkG2BpFpY=;
        b=YZ85sAwS7pFQ48UnMbH5NSuQSJAgGcy8WOWyrMwU3ekNKpeiHCmESy3i4MzBJdvut1
         tr2UrCzDCF/EA1R7X2m+gjDTikuEvmrQIwj8vDTmKk3T+Jr/9tbZ3/OU5R7b4Hg+t5d3
         vPmPa4675SIvQ00B4ytUbIZXDum0OL+EDx0PZ1BIzPYnBgryFVEv3bMKIDkQ7Tb3GamK
         x3vR/hcYsaCkY/dGEAE+6DeXWihQihtA6XpJWNCsF8DZ1BPtMyO09QRbXiPdOD0G+GMt
         WGEnetOwHuMFfzvJzIir2rRfhFoDwVtDbb4y0ZXahqkM2pcsr6e+79iBg4F5mP7nRibh
         gECQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=r4cOdXHt;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p126sor32640018qkd.106.2019.01.08.05.19.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 05:19:09 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=r4cOdXHt;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=i/LKjvpf6BLPa3asEup3mQ52HQP7Vz8QBeRkG2BpFpY=;
        b=r4cOdXHt3tF6VI2mRaC96JXzm+LW8Fyq4fm3nTPZRAFSTkA9ZoEMe2CJpG2Uq0B6Xw
         f1xtgC31km0Tv3UF9Mc+rhfMUMr8vj0IHfjbMClWJEqSSorQCCh4r1KIeK6Xd+55BYaT
         Ory/Gf/0Odpx+McUNZuLbZqhS8OisH2IZ19r50IsOn9QHnrWC6sIohX3kSbFxH3jVG8l
         YW4rUohSU+k4fm6y2TZAIEX33WqdpqGITfyox3Ii/j6ScK1EOAad1r4u0QoyESH/nlsG
         XUorc19KwV8b+h5cHUlkv8lmFyWyvEsdm7c5JZnIy4o9AltMHsVgKcatea3rmCMe5UiK
         KBqw==
X-Google-Smtp-Source: ALg8bN4EfDz/gH4Sx4+yauacZE3GN7ptChBDrlUda3BDiOk859i7j+25xadficCz1f6HR/IVwObZjQ==
X-Received: by 2002:a37:8b84:: with SMTP id n126mr1385998qkd.355.1546953549358;
        Tue, 08 Jan 2019 05:19:09 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id c17sm46343462qtb.14.2019.01.08.05.19.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 05:19:08 -0800 (PST)
Message-ID: <1546953547.6911.1.camel@lca.pw>
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com,
 mingo@kernel.org,  mgorman@techsingularity.net, iamjoonsoo.kim@lge.com,
 tglx@linutronix.de,  linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 08 Jan 2019 08:19:07 -0500
In-Reply-To: <20190108082032.GP31793@dhcp22.suse.cz>
References: <20190103202235.GE31793@dhcp22.suse.cz>
	 <a5666d82-b7ad-4b90-5f4e-fd22afc3e1dc@lca.pw>
	 <20190104130906.GO31793@dhcp22.suse.cz>
	 <e4ad9d12-387d-1cc6-f404-cae6d43ccf80@lca.pw>
	 <20190104151737.GT31793@dhcp22.suse.cz>
	 <c8faf7eb-d23f-4ef7-3432-0acc7165f883@lca.pw>
	 <20190104153245.GV31793@dhcp22.suse.cz>
	 <fa135cd8-32e5-86f7-14ee-30685bca91b5@lca.pw>
	 <20190107184309.GM31793@dhcp22.suse.cz>
	 <bfcd017d-dcf4-b687-1aef-ab0810b12c73@lca.pw>
	 <20190108082032.GP31793@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000009, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108131907.FS_H2VmkEzDOUnSjVLxpNDZAEkhrgRrBxZjsPYUFRaE@z>

On Tue, 2019-01-08 at 09:20 +0100, Michal Hocko wrote:
> On Mon 07-01-19 20:53:08, Qian Cai wrote:
> > 
> > 
> > On 1/7/19 1:43 PM, Michal Hocko wrote:
> > > On Fri 04-01-19 15:18:08, Qian Cai wrote:
> > > [...]
> > > > Though, I can't see any really benefit of this approach apart from
> > > > "beautify"
> > > 
> > > This is not about beautifying! This is about making the code long term
> > > maintainable. As you can see it is just too easy to break it with the
> > > current scheme. And that is bad especially when the code is broken
> > > because of an optimization.
> > > 
> > 
> > Understood, but the code is now fixed. If there is something fundamentally
> > broken in the future, it may be a good time then to create a looks like
> > hundred-line cleanup patch for long-term maintenance at the same time to fix
> > real bugs.
> 
> Yeah, so revert = fix and redisign the thing to make the code more
> robust longterm + allow to catch more allocation. I really fail to see
> why this has to be repeated several times in this thread. Really.
> 

Again, this will introduce a immediately regression (arguably small) that
existing page_owner users with DEFERRED_STRUCT_PAGE_INIT deselected that would
start to miss tens of thousands early page allocation call sites.

I think the disagreement comes from that you want to deal with this passively
rather than proactively that you said "I am pretty sure we will hear about that
when that happens. And act accordingly", but I think it is better to fix it now
rather than later with a 4-line ifdef which you don't like.

I suppose someone else needs to make a judgment call for this as we are in a
"you can't convince me and I can't convince you" situation right now.


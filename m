Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6E40C43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 20:12:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6822F222FE
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 20:12:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6822F222FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF78C8E012A; Sat,  5 Jan 2019 15:12:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA6348E00F9; Sat,  5 Jan 2019 15:12:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B94A68E012A; Sat,  5 Jan 2019 15:12:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 73E4A8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 15:12:25 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o21so36388551edq.4
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:12:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=LAhvqFRZ6hHdtYOT+npiTYOUGyR0EZjyGs1ho8vW3EA=;
        b=BWg+Ayw3MKYcpHjsKjGkTnvxQFtd2rviMmH4Xs2N0/kz1PeXrCPuT1RWj1nUaEa/BQ
         6Iq5NlxUXuG5xq/ABC1/SV7kWwlhEPukl9H33TpbJZWYJyGuO1heUZYetCqZpFHtZJCn
         8Eh2R5jxK+m1OrcK8ChGq24NowZWGVFZo335kdqp3RNPuRlKsu+bDgumn77Ct2K2+5Qm
         gsjwXzTB4wJHTcoLtpv4nxRFrZ2KBJx7gxvW8H49zCpvDd7Ac+5h1OKTX7UzuZhmdEin
         6/l91C0Kjmc9TfX0kfKqJybAp68+jCQ3DQfW06NQ+XCWKw1OuOHG9Oznzk9bx060/rI2
         okcA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AA+aEWYUAlIt1CMOnzcvaI627hJ+tJPHmCmNv8376dOvyd7WU05vEPnM
	Oo72aynbjrCI6vSbMgNDiGJT3z2YLOLi8BEYAOFgt+V8klorTfbSHDmpZEkX9YMjQIwqZz2bk8L
	qKV6D7KNuwRQBCsZ/nA98XCRBFileZgfvN4BsBK0DadSXeUIqXFOGsAiaNLmC/Ek=
X-Received: by 2002:aa7:d1d7:: with SMTP id g23mr48727786edp.217.1546719145033;
        Sat, 05 Jan 2019 12:12:25 -0800 (PST)
X-Google-Smtp-Source: AFSGD/VYf1n8SXaUCBAPiBChi39RzXyk8yy/8FSmmhB6mwT4BdB681FUK6QlV2mokiR2OpeKmr1W
X-Received: by 2002:aa7:d1d7:: with SMTP id g23mr48727760edp.217.1546719144302;
        Sat, 05 Jan 2019 12:12:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546719144; cv=none;
        d=google.com; s=arc-20160816;
        b=XraBEVxk0h17QR0M6FOMdQfEqJtDpW8orC5gxeMBiAFB2kANH7MHdanMbsyj60XGNR
         9iDgocaNWN48QxDnNj99uXnNQzQnsen7E8+A/zMomYcFxo8w5/IdNEF1lMGab0Pc3fCb
         v5kG/ojmV9huhYY3db7vQrIJYddH9TLDOt5dIiABl/K9MbkknPCZpdoTYnnamS15RqVA
         sd4Bt9cU1HPwXQcgOIJvcskAFGNKVw0dM/avF8fS0pOiGEFWRtqHx7yfdnjTDIz4H9Z0
         gTwrIAuzQbxYUQjeDHoG4Wka5oXjuGY4vzOgd/lhI79E54uMiRZufYDKfjmQdCHr7bAd
         AzTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=LAhvqFRZ6hHdtYOT+npiTYOUGyR0EZjyGs1ho8vW3EA=;
        b=QQSH3f4S1F0Wc7q278uHJMa0s+j/k0Gk7coHF02JNUzN6YohonXdkQu7Kqa6Znfwx9
         AF4+EoDuX7BHOga06ZdSePHcIaZLs01IVggiyJuCWW9qRWdQTI72bLN8QOH1q8QTn5sF
         ekxeCOoS2oOksUuLZhQt7a+oYHqr7oGYuvtTtwq1KzQvLA4/ujR5Wmr9dKVBW+aOmOh6
         i+9ICs+YT/VBDvhaI9FvqVFyOYlihNbX+WCoAHCWhUcGpfHcL/rxBDg7HAhOXyxxPh/e
         981HB05Yx9ZFxE3pgx56m2YX7FDfNaq9IvQG2VD7ESMtjiGuDJbFkp3piLUTI9u6WRKA
         NS6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18si143141edi.278.2019.01.05.12.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 12:12:24 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8E196ADBE;
	Sat,  5 Jan 2019 20:12:23 +0000 (UTC)
Date: Sat, 5 Jan 2019 21:12:22 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    linux-mm@kvack.org, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
    linux-api@vger.kernel.org
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105201222.1LsXvCPwYusPIbTMLYcqV0RX6SzNAyMygnuhC24SpOg@z>

On Sat, 5 Jan 2019, Linus Torvalds wrote:

> > There are possibilities [1] how mincore() could be used as a converyor of
> > a sidechannel information about pagecache metadata.
> 
> Can we please just limit it to vma's that are either anonymous, or map
> a file that the user actually owns?
> 
> Then the capability check could be for "override the file owner check"
> instead, which makes tons of sense.

Makes sense. 

I am still not completely sure what to return in such cases though; we can 
either blatantly lie and always pretend that the pages are resident (to 
avoid calling process entering some prefaulting mode), or return -ENOMEM 
for mappings of files that don't belong to the user (in case it's not 
CAP_SYS_ADMIN one).

-- 
Jiri Kosina
SUSE Labs


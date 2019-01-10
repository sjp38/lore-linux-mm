Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62299C43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 07:54:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AEDE20685
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 07:54:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AEDE20685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5F2F8E009D; Thu, 10 Jan 2019 02:54:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E6258E0038; Thu, 10 Jan 2019 02:54:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 887658E009D; Thu, 10 Jan 2019 02:54:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4469C8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 02:54:34 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id c14so5751556pls.21
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 23:54:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=AP3vwm5hJhQ37Qu1gNZNJyRbsEdNns+KLkKgtf0sA+c=;
        b=akMHhoS24TN8/Aq2rwNhk9pqgbdciRqwSXvCT1v++TaI4+FbotSUGGx9Bgd3m1kmLy
         hecDlris/neVnRstv//0Jel7lt96lOWjLnlkJ7S508isQapZXFodoprTm4S3cc58juje
         SpGSsFlDZs5cLHzC1aZjJ9vRvVa5NtBYTQTAGjDlzC7923KRWCrY0HvUMcuSd2X2uDPh
         xB3xiEuEycHimJ4DiiqwM5ZmrffGC2cZbDy0/P3ddBEI6l6Z8snMEGQ4tjJtK9DSaABl
         gWtFjzORA0+9cShJfjPWkXE+JN3u0qPQaE+6ATGfU2Pxx1DyR3SdWU0QPT3w+5H9CeR6
         6l6A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukd75XmKCVjHbuQrTChb51yP1Qyq1zk03ZnQWuVK2d82xrQ0iWCB
	In+6nvXg8jpK/mr5Bd30alxMIMAXPiuhZeX26024CQxD3eCWjRDYELlWegjCwEXcIkv0e818AQf
	9Z+CQ579f/Xbctc3bZfFUJf34Vp8e+iMOExemRaGkfY62MlGffqm5RfRvQKUF6Ds=
X-Received: by 2002:a62:5fc4:: with SMTP id t187mr9313642pfb.66.1547106873821;
        Wed, 09 Jan 2019 23:54:33 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4u6vOqqKxfuDmqviFHhpo+9W3gci4AT6CqJF0VfbAteSmoT30DV3SUm4tUBCN+2Vs1u2VC
X-Received: by 2002:a62:5fc4:: with SMTP id t187mr9313612pfb.66.1547106873007;
        Wed, 09 Jan 2019 23:54:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547106872; cv=none;
        d=google.com; s=arc-20160816;
        b=ee1YKmKmljBBc0FjvlHASMrbRWHOx4wGzbfjBaPwtqLVAyilqQXKdVsdN3qvvWKI58
         d40jt3dbA0jzwhkv3y9aQ4zeVLyo2K4+SpLwOBp0w2dEYQRY3iIsBpqQ1+gaNjVUneVg
         cs9mLFjbMcqTcgCgsKvvsLCKifnvc6OE4tK97Df92c6UQ4hQp+yGOoiT0Tlx2YxS6DUb
         /Bu+ncrWYfsADia2vVes2VdlHqkEypJsrZMnmyyododWaYfir4/23uZAEKxmTuNEyLW8
         YS4h9DBlWT5j685gE/shOBpW1uwraYgoGI0+gJHetpohJQ+GAPWFNKd2PSi+fPCQM2AS
         4f/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=AP3vwm5hJhQ37Qu1gNZNJyRbsEdNns+KLkKgtf0sA+c=;
        b=b9ZWdnvFRYcA8GxrOMPjwnEcxIq7NsTZGq5A4BtTQAvrfjxxoV+APZKffIVYULL0r0
         sQ196PY+lBr5FG3DN1DQms0suZWRXQ9NtW22Kn2/4GgMz0V9RHk2tDWpturgi3ZrMwMS
         dyqtONb4Ls/53v9yfF6ofux1tOENzJ4/5PLHwprSMJJJRJWGFXVknVZwt8gpLszzwLnp
         Tc5c4LnJue7lIKJGc/j0MlInH8F/wevpE3sG2/F7ashNXDZ3Ha0ObfN4qvkmoMWWEYZ8
         g/zfCiu2IplbOLOz4kDefQYVGOvjECD9Z+tZWJq12bqUCu4Fa7iAxKXcHpvYXOElsfaw
         79uA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h127si5946522pfe.204.2019.01.09.23.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 23:54:32 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 10AADAC6E;
	Thu, 10 Jan 2019 07:54:29 +0000 (UTC)
Date: Thu, 10 Jan 2019 08:54:23 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Dave Chinner <david@fromorbit.com>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190110011533.GI27534@dastard>
Message-ID: <nycvar.YFH.7.76.1901100852080.6626@cbobk.fhfr.pm>
References: <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com> <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com> <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com> <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm> <20190109043906.GF27534@dastard> <nycvar.YFH.7.76.1901091050560.16954@cbobk.fhfr.pm>
 <20190110011533.GI27534@dastard>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110075423.mh8V6epx1DO8kNKg8lKrAFB_C96IxpQ9vNKFasU3Peo@z>

On Thu, 10 Jan 2019, Dave Chinner wrote:

> > Yeah, preadv2(RWF_NOWAIT) is in the same teritory as mincore(), it has 
> > "just" been overlooked. I can't speak for Daniel, but I believe he might 
> > be ok with rephrasing the above as "Restricting mincore() and RWF_NOWAIT 
> > is sufficient ...".
> 
> Good luck with restricting RWF_NOWAIT. I eagerly await all the
> fstests that exercise both the existing and new behaviours to
> demonstrate they work correctly.

Well, we can still resurrect my original aproach of doing this opt-in 
based on a sysctl setting, and letting the admin choose his poison.

If 'secure' mode is selected, RWF_NOWAIT will then probably just always 
fail wit EAGAIN.

-- 
Jiri Kosina
SUSE Labs


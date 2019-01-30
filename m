Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44C5AC282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 15:04:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 109A320989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 15:04:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 109A320989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2ED78E0002; Wed, 30 Jan 2019 10:04:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DD288E0001; Wed, 30 Jan 2019 10:04:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CD3B8E0002; Wed, 30 Jan 2019 10:04:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBC68E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:04:46 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id p24so29079881qtl.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:04:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=RFHJCwGGFjug4k/yqoI/yFl11Q86KTQkVM3Lko7swq0=;
        b=C90YDtYUosA5nYHEth/UsZBBELcSAF0sJWuCZdUGlbPBqHrU0L3vl1AvWg9lA+sdd3
         Q1NJpI43Wdk5Ov6jEMPawDeMG10yJx9INUvrTAx9FgBhh5R3cagSLdgm/alabjx8NOKH
         fvNsHwaM/K+oWKOx4Y+OQEdoiEkgRz4rPJPdPKSjcs35alr94uHFFn37Hq76/kBBUSYk
         Zge+1rU9LJSJHVTuh67lt9XDPuPT8zpvlXJXbr27ekeH4vq9f/DmQQF/+0matlPPuXd8
         r7lnnmVruvi4DenoM0lLQg2g3LXn3SRfbrv74bSjnwAnnl229Pliw8yJdxzZu4eAU+0x
         w34w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUuke9Yul8o3wVpQFy42Xk2JbMsU4boOMECLKHAsBfTU2MC8W4SsOG
	lUWX4/XanBYPKGfeyqQ/x1GpUZ4Bk+QfELZlUCA9ZCIIGLVhWNLCRXjfXY+XfCkNDEr1Wft9L+V
	jAFZEd7Z3K4O9i/pgJDkKDVej/fbYQNf2Kd1gtWKXAwTz+jO03CLgTbIFFc9RACjlmw==
X-Received: by 2002:ae9:f212:: with SMTP id m18mr27181305qkg.5.1548860686104;
        Wed, 30 Jan 2019 07:04:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN47g8uTKnKttyFrgsIgy/X7zJl3OBynk8UtgBM664ktUOq8r/WY3R++0gQ1CSK5+JAXbLJu
X-Received: by 2002:ae9:f212:: with SMTP id m18mr27181251qkg.5.1548860685436;
        Wed, 30 Jan 2019 07:04:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548860685; cv=none;
        d=google.com; s=arc-20160816;
        b=zfLpDbUE6fmYjotrYWs+uEFovG2zwgGhzQ2nk9L/r8JlDkWmo2RzsfIBWaJoF87HbC
         gHrBuGZ9qud2gwgViUQVcJSfZmrZerdrk0Ewx/LvJl2hN72UnizZJY/Goy2J99gCCCrw
         9Q0fWTgt6Ajnz76hANMYvqf+JkAmGVI3s2zE6A1TP8fOLu3+f1jqWK+i3k6WcqiPFRgl
         icblLGVM9BqrVrPMyfyyB9R/2KF2BCEwAakYSUJjGZd9pa5sDg1hjme64IGHVBWYYUrl
         vMU/N7wjJP4ZxbtydAlF/FGj9cwltQY4CYltrM/MIT133rghOc5od9+Rw9P6kGQP7aZe
         /LPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=RFHJCwGGFjug4k/yqoI/yFl11Q86KTQkVM3Lko7swq0=;
        b=rGMHAO39otCQrEgHiwgf6M7unf0HlQq3rM+q0xy9LkEisaN4eh2//WBC+IcTdw1/kc
         kdrvSRCqXK3XB7ViLDWQIS0p5GdPzup1ZUIFKUEy6PG4WG0/3swCjjn8IKP1unG0heIb
         bTlT+d2ZJVys/jf2dbFD/8IcGTYzgPJtbJWCNFUGPJdJq+CMehhq77cIobYuw2IOkdRu
         XeT6mPTYbDWKn6VX+mojynd2AzL7yTD9c0OHzRGoMeXSiBoqljV+yJvxJ62CVAFBJWBQ
         pV0G3GeAyDa1NwO2ZtD39+BIPVNvITujqGQ1CP/5U+JlRUVvLMrdora5GyKXQLYl3jGp
         TODQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s21si1218636qki.43.2019.01.30.07.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 07:04:45 -0800 (PST)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1761D155E0;
	Wed, 30 Jan 2019 15:04:43 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (dhcp-192-219.str.redhat.com [10.33.192.219])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D198D100164E;
	Wed, 30 Jan 2019 15:04:37 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,  Linus Torvalds <torvalds@linux-foundation.org>,  linux-kernel@vger.kernel.org,  linux-mm@kvack.org,  linux-api@vger.kernel.org,  Peter Zijlstra <peterz@infradead.org>,  Greg KH <gregkh@linuxfoundation.org>,  Jann Horn <jannh@google.com>,  Jiri Kosina <jkosina@suse.cz>,  Dominique Martinet <asmadeus@codewreck.org>,  Andy Lutomirski <luto@amacapital.net>,  Dave Chinner <david@fromorbit.com>,  Kevin Easton <kevin@guarana.org>,  Matthew Wilcox <willy@infradead.org>,  Cyril Hrubis <chrubis@suse.cz>,  Tejun Heo <tj@kernel.org>,  "Kirill A . Shutemov" <kirill@shutemov.name>,  Daniel Gruss <daniel@gruss.cc>,  Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT is set for the I/O
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
	<20190130124420.1834-1-vbabka@suse.cz>
	<20190130124420.1834-3-vbabka@suse.cz>
Date: Wed, 30 Jan 2019 16:04:36 +0100
In-Reply-To: <20190130124420.1834-3-vbabka@suse.cz> (Vlastimil Babka's message
	of "Wed, 30 Jan 2019 13:44:19 +0100")
Message-ID: <87munii3uj.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 30 Jan 2019 15:04:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Vlastimil Babka:

> preadv2(RWF_NOWAIT) can be used to open a side-channel to pagecache
> contents, as it reveals metadata about residency of pages in
> pagecache.
>
> If preadv2(RWF_NOWAIT) returns immediately, it provides a clear "page
> not resident" information, and vice versa.
>
> Close that sidechannel by always initiating readahead on the cache if
> we encounter a cache miss for preadv2(RWF_NOWAIT); with that in place,
> probing the pagecache residency itself will actually populate the
> cache, making the sidechannel useless.

I think this needs to use a different flag because the semantics are so
much different.  If I understand this change correctly, previously,
RWF_NOWAIT essentially avoided any I/O, and now it does not.

Thanks,
Florian


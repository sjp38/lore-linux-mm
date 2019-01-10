Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D21D5C43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 12:25:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BBF021783
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 12:25:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BBF021783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codewreck.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17DAD8E009D; Thu, 10 Jan 2019 07:25:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 105388E0038; Thu, 10 Jan 2019 07:25:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F10438E009D; Thu, 10 Jan 2019 07:24:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 956548E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 07:24:59 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w4so3074472wrt.21
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 04:24:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Bj9SgAAar+FM+heBVPOYbcXkQWmnAQZTH1pNA0xI7ZM=;
        b=ZhiH1F1ZUi+Wyiod3OM6w1TgPRVfUvqufIt0OzgIk+HgTlGeiviV3bc1vuMEiRjcE4
         pyQYU+CUnIORXim3fPcNfq76cD16g7sr7wnWXIu6XFHLh4p4vT6bZSDxDeY23oM7ttu9
         9BLHvmuPo7hI6iZwZfgKkKxecNOEJ3aFANWQLH8gKJ3OU7e+NAb61sSpmi7dvMyN4Nhw
         UorHCVkrzNpYpDl+W4UwRwGcQdpYfbGSYcRbM59wp9ZLQys0Ns+uYDoxAJz/YvxNFNCy
         kuda3hGI6RZBidooU6h+WebJ0SLe6stNQICuVCZCNIKb2FOG/wVlBREy8mwn9Mu5SYvQ
         V4ug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) smtp.mailfrom=asmadeus@notk.org
X-Gm-Message-State: AJcUukdR+aU0jPbuulMnHhhX+joYijSAFgKjWl8OpxzVnDQiKkC6kuPs
	BQ0jbu2GIzc0aHpJgWwu1YQ6xc++ytFI3J/tHWGgIAWWKdT8iCn1O8jbsggmCimyrOte1STcnak
	S3JS7EAku2pYJ645ulLcRxkE4v3VgsTNa3Kj8lYiGXs1KdHbdSQNeabbl1I/pOUE=
X-Received: by 2002:a7b:c04e:: with SMTP id u14mr9887630wmc.113.1547123099191;
        Thu, 10 Jan 2019 04:24:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN50LBma4IhCsOHi22y9JhBkICQoer19pcHr/D2HHx+DhNZXqn1BPSUg/hoOuUV5WUlJC8bq
X-Received: by 2002:a7b:c04e:: with SMTP id u14mr9887584wmc.113.1547123098274;
        Thu, 10 Jan 2019 04:24:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547123098; cv=none;
        d=google.com; s=arc-20160816;
        b=c4YJltJ5UunMV1cKih/4s1jk/meWX0LE+WjQw7sd33myaET3SYHQ6MN1pPkrUdKBEk
         8K+2t8GaLvdCTDRrpPnqK7ynasGhcZwVlqEF19QRpUfZhqkOHr+ObwCTYWO4hUtnzj7/
         eKQnr0tPFBxY/bE5/OKlxqZqLEQBC6ylsjffMrAdj+1OZnCkhFExt/bHRsanUPYw0WLZ
         2WFlmnSO74jYQLtc6oWDhNNqa/9M0NMR7y+SJORgL7QWkyXuI48apMGDQG5ONS5M/BCo
         dQjdvHaZkagTzvY8pqCSIfJE8Iu4BuZk7O6ZtTWW77dR40N8uG683XDBESedKWKaELJ2
         1aXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Bj9SgAAar+FM+heBVPOYbcXkQWmnAQZTH1pNA0xI7ZM=;
        b=RxMVJ+2c6s9+8HLU3VcKHxB38T0Eo7+E8wiaYBaR/Pred7h6So2uwLq/OB6Ck/zeWc
         Erl3Osto88tSGkSJ6aeBvxi5frPW09Hfo+FcdiWJbES1xZabFSL6GZhLpX2pHvyFCV2r
         X6W6qV+Jqy+btGK4TVnHQlkmdasW766kmeoQz++e7nNsk4wbMRIkS3ZenVMMrIfrki1/
         7fG4ZpqoYUHFgVjAYHDtAmvP9ue6nFhUiVKtQ6UgLHHyOPNiYI283D8JLDPlVW0i8bXl
         STJj079dSQk8B6p0oQ2T0NqnlCx7vvBhyLnat5FXssTwJCLTx1lA9J1dElNNXzcD4fHc
         R6xg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) smtp.mailfrom=asmadeus@notk.org
Received: from nautica.notk.org (ipv6.notk.org. [2001:41d0:1:7a93::1])
        by mx.google.com with ESMTPS id y8si686927wmg.178.2019.01.10.04.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 04:24:58 -0800 (PST)
Received-SPF: pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) client-ip=2001:41d0:1:7a93::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) smtp.mailfrom=asmadeus@notk.org
Received: by nautica.notk.org (Postfix, from userid 1001)
	id A84A9C01B; Thu, 10 Jan 2019 13:24:57 +0100 (CET)
Date: Thu, 10 Jan 2019 13:24:42 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>,
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>,
	kernel list <linux-kernel@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190110122442.GA21216@nautica>
References: <20190108044336.GB27534@dastard>
 <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard>
 <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110122442.D-AxJ19_1du8oZjG2Qz03VZ6BithvpXW57quzDRINAs@z>

Linus Torvalds wrote on Thu, Jan 10, 2019:
> (Except, of course, if somebody actually notices outside of tests.
> Which may well happen and just force us to revert that commit. But
> that's a separate issue entirely).

Both Dave and I pointed at a couple of utilities that break with
this. nocache can arguably work with the new behaviour but will behave
differently; vmtouch on the other hand is no longer able to display
what's in cache or not - people use that for example to "warm up" a
container in page cache based on how it appears after it had been
running for a while is a pretty valid usecase to me.

From the list Kevin harvested out of the debian code search, the
postgresql use case is pretty similar - probe what pages of the database
were in cache at shutdown so when you restart it you can preload these
and reach "cruse speed" faster.

Sure that's probably not billions of users but this all looks fairly
valid to me...

-- 
Dominique


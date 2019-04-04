Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AEB6C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:28:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC381206B7
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:28:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC381206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CA366B0003; Thu,  4 Apr 2019 09:28:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74F016B0005; Thu,  4 Apr 2019 09:28:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6178B6B0006; Thu,  4 Apr 2019 09:28:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7F56B0003
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 09:28:43 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id p26so2195002qtq.21
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 06:28:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=7yyf+HgxleLYBHaKJbIu80u0jEokOC4UH8AehtEvcEM=;
        b=TSoB0i/1RgNwkE9gj1bmKZ99rbh3edAUKZFJS+m86Qu59XEVjvSIwHHIKAZyYWZpBz
         jNoH5siVIJq+DfBXCzTz5iPEr8l4ad+PQjhK/2tDzJCV6sFSpdEVHSby5lWqfhhxxFw5
         d2OPhyC3ecohvYK8y/Afeu73ZDjUrcDRA33AQXCKWlf7wkf9dqGkJOXdIAeEYOMRj8yy
         EOVajyH1SesvkFyGs6+H55nQKpN7saUiqgzCGyFzslaLKVByS7RUc9yRiRZM77lgQg0V
         gqo7Hnal7qSBNsQPV90ZDNJccZnIUQkrlsqBuGVo1ysn94Aqb/eg+LPUlsYjP5m02Ka/
         Gx1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXpyaXdUDYYWMHUT1tme+1vM11ONaENi9KGFzv1Geljk/UfzmvP
	oKWiYF2bQbc1gSTzJyEZUGxpROhjfreVyje6sBeFcjkAI8zIMvlyrDzWJ9JfDHa5453tdaAFl+2
	SmID/sCrNrBEqCQ67nz+SdPlP6yuLKVB5lI9gptrIuAjxHKeRAtRcZgRvTFP5mRpNiQ==
X-Received: by 2002:ac8:35ea:: with SMTP id l39mr5507888qtb.151.1554384523060;
        Thu, 04 Apr 2019 06:28:43 -0700 (PDT)
X-Received: by 2002:ac8:35ea:: with SMTP id l39mr5507837qtb.151.1554384522357;
        Thu, 04 Apr 2019 06:28:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554384522; cv=none;
        d=google.com; s=arc-20160816;
        b=RpCKq9QM8cD/q+ECIKd+pX0p6+RY1th/KPl0y5onOL+olTFwG8l8ppDl9xBKJ+RrhR
         vT11eZBj3LYNXesVBhFDHTK7GNvyLpSKsGiWAE5oZZ0aRWDmUTZMIpU0SbNhahMmr108
         2GTEbXHibyz3avZtGZMgCgI9y1vdFaAwGV65V67c8YCxZBRXAgISq8/3OfhTy+yCl/fE
         JyJjVJ6RKzAPf+MJOOwSWr4H7Ie0+EorpZOb8mNL9xZPqfz2pjxr3gCOWs1YWQE1OPvY
         uaqYJXneAMEfMgwrVk5aVNcz7Knm8o/Oh8Ge+sPm7syW0JeQc9UE4AmSBH1tD0EU7WPK
         bJ0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=7yyf+HgxleLYBHaKJbIu80u0jEokOC4UH8AehtEvcEM=;
        b=uvcsqv/izbgnYAzGnwOdoI0CNdu2GTeBDY4GAzyHlAGombHH0Y8ro9Q+ToMwXr486Q
         YJtzwX/smc4ehSVPe5xMkou0949FLmR2ugMrLe+kC6gg42QnWw0Rbj+eqEa5uV8aIhMT
         i5B9DVz6gkiLWUEgbn5gCGzKp2WaHOmr7I/ycHm4E528Pd7zomcaQNQwwErfMJVZZ9Bw
         5JU2Q/mIVpxXVdBx9ts9+64QShHLcSW8F+ZohKdDN/KKaE71ODn2vGMSXIKqTx063kBY
         7m4ilBFzczgG065+Q77QbRPVBEaldjcQSwXMA1i+0QHceUax16q6dzgdrX8fZdf5dgqf
         Bq5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 55sor26390686qtu.34.2019.04.04.06.28.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 06:28:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyGfRXpzQFNaSliZNlz6/G8SzOU+HMRc8xYFoGZ0ZQbt0QhYGmCO8b8oYZ6Q0w9Htvlju38sw==
X-Received: by 2002:ac8:28e9:: with SMTP id j38mr5244597qtj.297.1554384522144;
        Thu, 04 Apr 2019 06:28:42 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id q51sm12443768qtc.38.2019.04.04.06.28.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 06:28:41 -0700 (PDT)
Date: Thu, 4 Apr 2019 09:28:38 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: On guest free page hinting and OOM
Message-ID: <20190404083321-mutt-send-email-mst@kernel.org>
References: <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com>
 <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com>
 <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
 <1249f9dd-d22d-9e19-ee33-767581a30021@redhat.com>
 <CAKgT0UeqX8Q8BYAo4COfQ2TQGBduzctAf5Ko+0mUmSw-aemOSg@mail.gmail.com>
 <0fdc41fb-b2ba-c6e6-36b9-97ad5a6eb54c@redhat.com>
 <CAKgT0UcrkXKjMgYy2H3MKQxG71ScNqhwqxwti7QjvPSxtb8FBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UcrkXKjMgYy2H3MKQxG71ScNqhwqxwti7QjvPSxtb8FBg@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 04:43:03PM -0700, Alexander Duyck wrote:
> Yes, but hopefully it should be a small enough amount that nobody will
> notice. In many cases devices such as NICs can consume much more than
> this regularly for just their Rx buffers and it is not an issue. There
> has to be a certain amount of overhead that any given device is
> allowed to consume. If we contain the balloon hinting to just 64M that
> should be a small enough amount that nobody would notice in practice.

I am still inclined to add ability for balloon to exit to host on OOM
if any hints are outstanding.

If nothing else will be helpful for stats.

-- 
MST


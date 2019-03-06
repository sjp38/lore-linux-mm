Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A33ADC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 20:32:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 587BC20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 20:32:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 587BC20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BB6F8E0004; Wed,  6 Mar 2019 15:32:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0425A8E0002; Wed,  6 Mar 2019 15:32:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E27DA8E0004; Wed,  6 Mar 2019 15:32:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4D438E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 15:32:13 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id i36so12755177qte.6
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 12:32:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=zdlXK/K9DrmgdShzIBPYnOPsskIKfhagYRirY+udO1c=;
        b=gUrEGIqB/rprFsJvp0cp724PqwXkwGYO/kdM3rpChTBTLoIE2YE3DrNhDD5vrYc1Ov
         WIQ37vJEkXJrx1sx8TyGizYIJLGqiIXegGNxUyqGwOD9nabMFzCbtkjabGsBjF7E/qRs
         g88GnkovvyOCH6JtlY+TteHDggwL+IpUmrh0XjOY9S951e51eLd9nG2mcWNLmNjYires
         nG0pJ4Iuas+HCGQArecluA7wrQnI64zbcGWFMuahHURQ8Yx6deB9bY67PYAVBjMntULP
         Ob1xKZ+vRzuEzE6mCHWdJwX9ARSzr1c3eFrAopQh4t2h9p/Ki0iSE86bo1IKcD4b1/Os
         F3TA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUPerKfimsZ5oXWUdVHVxhEPaz2DjSzxPs8eAPa2SdYxM++9icn
	+HD64S87B7CHfRUQ3rQyXJhTIWzyijcEVg50Zw8cUp84Bx8EkEu2ejdXOqxlFreUMXhEBNS+T9E
	pqLL+Sfl6y1tr/6YQrJEZU47XfLgF4HK/QHB9rLMN+f8jpx+Ooc54eZmtE/0JBOMt6qrx3K1Tyc
	z8I3HS51uNKzjablPQf6lomropYW/OAoAxFbxEQzqUdeoMZt5KiPhNFmhYJyCYev/Hwi3zSjGTJ
	gNap+MN1GvvhxkY2RuUKlZ8dVyp6UlM098Ja4NrGUgqvi5AxfQ4+tcImxQ2iHqslfBlsarMgZ0f
	Bj4XU6tXJOckKCM5J6boEWbw0iFJmuode00p7KJOd6xwbUmViTMPy49Plhzfk+/K1JGqAp9g+D1
	g
X-Received: by 2002:ac8:fbb:: with SMTP id b56mr7490449qtk.41.1551904333523;
        Wed, 06 Mar 2019 12:32:13 -0800 (PST)
X-Received: by 2002:ac8:fbb:: with SMTP id b56mr7490371qtk.41.1551904332392;
        Wed, 06 Mar 2019 12:32:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551904332; cv=none;
        d=google.com; s=arc-20160816;
        b=A6GJWH1z8gw3FlhmGgql9TneH8zDpmms5GNegdIAaSE7XBNhvA2t4qza7reDLnI7ap
         B4MmiNQVzlTl99FajAfY2rGsL30Zd4gZkSulKTizPPc/1hCpkUyQgOlUj/XWzda6Keqb
         ESY+T06/9cm63iWeLG6/Sgg/0zE54fwJriZsDH+UsiYnih53imZ8yOB23NYYnL6RF4/S
         yAae5gFlirsROSO0gNOvaFsvM/Gssn1qxO2/nG+BSmy41Eg65iAguRvK/GfKDrUP0ghH
         XHIFUhPILufv8ZCmP2UdkfdN7ovvuRJkTcX8gUASHu8v0v8EDu5rhy5V446IPX3p5TBQ
         ZlVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=zdlXK/K9DrmgdShzIBPYnOPsskIKfhagYRirY+udO1c=;
        b=qe7peqguity/kt5eg6Zs2DyA74UNJ7QUsHO87eY6FjnQP+QB1eabQ2Wlfw61i1KIMG
         hSTa63NbGx5ZmYDP02CELWWTik2/WraihkQf3QnqYisoQujWj8BetzT8VnEa60nItVZa
         zMvdo8ADJoSU6ZvsMZZ3LlKxXkytj5l5c8wg8dATk/u8acHDP8vMiFr8yal0x4l/8XqS
         /Y02z4XhNkNSUvY8rXf2wM9PNjmzlrapkSjEcXU1nR3rXs4g91hVVfTOK0oryzSpGf5h
         WGfXwyLxOCnqDO9+R55b8CCrtOoHj+2fRbI4FoE95nrbD3dfLr9BHVQllB445RjeGdMk
         YGmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w3sor1678043qka.89.2019.03.06.12.32.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 12:32:12 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxms3WUU7IeqX32+lnwJ/uUR/49fW9yRJm447yiqeryyZJ3BJoAMav/eWIlJ6fELpmiv5iJ0g==
X-Received: by 2002:a05:620a:124c:: with SMTP id a12mr7158890qkl.103.1551904332106;
        Wed, 06 Mar 2019 12:32:12 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id v25sm1108008qtp.92.2019.03.06.12.32.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 12:32:10 -0800 (PST)
Date: Wed, 6 Mar 2019 15:32:08 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
	aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
Message-ID: <20190306140917-mutt-send-email-mst@kernel.org>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
 <20190306133826-mutt-send-email-mst@kernel.org>
 <3f87916d-8d18-013c-8988-9eb516c9cd2e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3f87916d-8d18-013c-8988-9eb516c9cd2e@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 07:59:57PM +0100, David Hildenbrand wrote:
> On 06.03.19 19:43, Michael S. Tsirkin wrote:
> > On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:
> >>>> Here are the results:
> >>>>
> >>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with
> >>>> total memory of 15GB and no swap. In each of the guest, memhog is run
> >>>> with 5GB. Post-execution of memhog, Host memory usage is monitored by
> >>>> using Free command.
> >>>>
> >>>> Without Hinting:
> >>>>                  Time of execution    Host used memory
> >>>> Guest 1:        45 seconds            5.4 GB
> >>>> Guest 2:        45 seconds            10 GB
> >>>> Guest 3:        1  minute               15 GB
> >>>>
> >>>> With Hinting:
> >>>>                 Time of execution     Host used memory
> >>>> Guest 1:        49 seconds            2.4 GB
> >>>> Guest 2:        40 seconds            4.3 GB
> >>>> Guest 3:        50 seconds            6.3 GB
> >>> OK so no improvement.
> >> If we are looking in terms of memory we are getting back from the guest,
> >> then there is an improvement. However, if we are looking at the
> >> improvement in terms of time of execution of memhog then yes there is none.
> > 
> > Yes but the way I see it you can't overcommit this unused memory
> > since guests can start using it at any time.  You timed it carefully
> > such that this does not happen, but what will cause this timing on real
> > guests?
> 
> Whenever you overcommit you will need backup swap.

Right and the point of hinting is that pages can just be
discarded and not end up in swap.


Point is you should be able to see the gain.

Hinting patches cost some CPU so we need to know whether
they cost too much. How much is too much? When the cost
is bigger than benefit. But we can't compare CPU cycles
to bytes. So we need to benchmark everything in terms of
cycles.

> There is no way
> around it. It just makes the probability of you having to go to disk
> less likely.


Right and let's quantify this. Does this result in net gain or loss?


> If you assume that all of your guests will be using all of their memory
> all the time, you don't have to think about overcommiting memory in the
> first place. But this is not what we usually have.

Right and swap is there to support overcommit. However it
was felt that hinting can be faster since it avoids IO
involved in swap.

> > 
> > So the real reason to want this is to avoid need for writeback on free
> > pages.
> > 
> > Right?
> 
> -- 
> 
> Thanks,
> 
> David / dhildenb


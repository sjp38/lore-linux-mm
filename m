Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E986C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:15:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B3062171F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:15:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eICtM3WJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B3062171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FDBE8E0003; Tue, 12 Mar 2019 13:15:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D4B18E0002; Tue, 12 Mar 2019 13:15:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8ECCA8E0003; Tue, 12 Mar 2019 13:15:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36F068E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:15:54 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id a19so720851wmm.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:15:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JJNmxFq4kvtgDMxGW5EQZmwTBHXCE8cD8UO0j6EqecE=;
        b=blZB1H456sTsK6Fmu/OyDQ8LuMJyrvunDzQe8rqVGi9UBFDwGV0BiOJwhX2zJ8AX+g
         uhXC4hvLchn0JZyiNyOCgi/fp+Qhhc0VYfF5xoPGm7OQvqgnBfuBrfFDqbolxdNJp8MX
         77lgwl3S6iulXrFGUv3JL6Ld5XEMumhYqCng7zb2M+uqNrndKRL8boW/qAwH5UVyP9TF
         i60uqGIA3L43PXVRAyPeJ5Lf77zXSJmvD5/9qELu+peyKz6ET04x8zZTlYo7GTkoVNBt
         Dm8oWe4NEjaVf4cShqizQEQCSVHdN4CcP/M2vJXvhBreIvh4CUb7sFC16nEHbdkSl8GD
         26vw==
X-Gm-Message-State: APjAAAU+K3X6czPhk/Qe1mR57OZQwU6rPLRZfYM1lNNMWo3CWIw7Q3Nx
	3CU3up+cGf1H6n99B9XItr0LVuz3uy74MhaKOH3jd6xwOwikuYx/9ksF00B0ReT8aGdM3xIVsgG
	wTNQsppbTOY+8RmztSb8/a1k45BebdQ+rj+8Pb/Nwmt1Jw4FDrsEJiGFRsHCF+ChvKw2oorQy7I
	DoueU9RrqNGSoe6U0j6Lo6YX9omOfqmd8qsQ0OureXAEsfGc5LIP01bZDjgt4Iw2zrCDLyti6yh
	6du6nz87Dz5EIs7lkPz1BynMSC+unKsqhV5HTeN3tS2zszA4LuI+WrDIBDnkTeXVUy5tNCf/eI0
	9iT0JGOgTXPkcQfXxlgnSwHuQI4D5w5A5OyfrbCZg3qP7DLSAHKw6GDqN7X0qTpw7SEy3BFgRIl
	q
X-Received: by 2002:a1c:5fd7:: with SMTP id t206mr3166091wmb.73.1552410953817;
        Tue, 12 Mar 2019 10:15:53 -0700 (PDT)
X-Received: by 2002:a1c:5fd7:: with SMTP id t206mr3166049wmb.73.1552410953029;
        Tue, 12 Mar 2019 10:15:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552410953; cv=none;
        d=google.com; s=arc-20160816;
        b=jkQEE1xG7nrEyyLoymis0lxbgFNpNewGVWSa2L4t2QQs9/M0uG3a0Od5dzKsKFIlmf
         pne5Vh2O1OJBUSLUNOtCSuVdK2zP8n/6PnTjhf/sT69LqEoFWF7oAgF3LNGOnhxCjA0D
         oG65PmjQY1ilzJ4nigGQSblbtTW8HuyrhHOZPtfGhYUda2+eoZb+YejKVDKE2x0V+Agq
         gCms/PHPLMExicL5A3qD4jDOixIbMOHYkne8NPQ3UJYU2USjOggzduohSUOG27fvc6Hn
         XlV5jxsR+CQOujxzosACoPSymhKz3VuNXz0gPjWH6LN9ZgHnkYOUqmphKxGUACbb8I0X
         06Ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JJNmxFq4kvtgDMxGW5EQZmwTBHXCE8cD8UO0j6EqecE=;
        b=oLvU0aZUBgoUYVKz6Ja1ieJ/EcTDBC31xSiapeutWtrEFCtSVyGOXGjoCWnQyj+VcP
         YhTUCaOZfbhFkccrI9K09LQlVnWXKtQP3fDBcMIitYmbsEggR1UhfoUjnP77GH0U7ImP
         hliGvTwcPXMhskKK8cEDClTmp+P9P9wXj0GOPlsBvzwG5ZOWakPTNU3ZWd9beIWxtMnj
         9enkOSmeJEuHoY3rx8q7HY7aPZBGs2orfhcapn7AJTvEmzjUNJGwkXxBzYt1kqe2wqjR
         v+YnUvziknNomr5ofoX0aBZZWwCFceTjVxggWZNowkc7oYfZ/HGXOD+xNnAGQ84AG29R
         r96A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eICtM3WJ;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y3sor2133661wmj.10.2019.03.12.10.15.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 10:15:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eICtM3WJ;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JJNmxFq4kvtgDMxGW5EQZmwTBHXCE8cD8UO0j6EqecE=;
        b=eICtM3WJdg7Bq7C7keVDYg0CrinSY8xGGeQG45rEmu59uiZfjFMczd9uA/UYhoAK+g
         hCH2sfdCvx95nRGUSuHYhXxnYObCMQL27F3dvIFV/nD0pkzS+RWsuLvO20H3uohxUK8Q
         bFWGc02dYBQDpx9KIr9IkMTpmmOLw6OjlJlPjDrBDeBbHlAJFaklVRj5VOu0U31Btj3D
         Y2PvQxG1UvzKcsj7by517lkcVQ00sM0No4sycN/PgwxHIT9WthtTO4uSpYByiS94nf9g
         UJ6r3xqwjS105/10FTzY8I8djkMo+4TPDnzH9B4ZzIGH0kaWVK0ouPit1AgkSDsEVjT0
         4K0g==
X-Google-Smtp-Source: APXvYqx87Bwal2xirLDgWzJL461s60oU++NHtJORE9GT9nlzsH1PR8HvbGpV44aPviSqK/l38j0DtUaUXf28zAVP9qA=
X-Received: by 2002:a05:600c:2115:: with SMTP id u21mr3406355wml.70.1552410952458;
 Tue, 12 Mar 2019 10:15:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain> <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
 <20190312165805.GF5721@dhcp22.suse.cz>
In-Reply-To: <20190312165805.GF5721@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 12 Mar 2019 10:15:40 -0700
Message-ID: <CAJuCfpH9emgP=iaMy2_BEJ6HT3vvrvoeqTrCUXeBBD9VNR99kA@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Michal Hocko <mhocko@kernel.org>
Cc: Sultan Alsawaf <sultan@kerneltoast.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Christian Brauner <christian@brauner.io>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org, 
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 9:58 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 12-03-19 09:37:41, Sultan Alsawaf wrote:
> > I have not had a chance to look at PSI yet, but
> > unless a PSI-enabled solution allows allocations to reach the same point as when
> > the OOM killer is invoked (which is contradictory to what it sets out to do),

LMK's job is to relieve memory pressure before we reach the boiling
point at which OOM killer has to be invoked. If we wait that long it
will definitely affect user experience. There might be usecases when
you might not care about this but on interactive systems like Android
it is important.

> > then it cannot take advantage of all of the alternative memory-reclaim means
> > employed in the slowpath, and will result in killing a process before it is
> > _really_ necessary.

I guess it's a matter of defining when is it _really_ necessary to
kill. In Android case that should be when the user starts suffering
from the delays caused by memory contention and that delay is exactly
what PSI is measuring.

> One more note. The above is true, but you can also hit one of the
> thrashing reclaim behaviors and reclaim last few pages again and again
> with the whole system really sluggish. That is what PSI is trying to
> help with.
> --
> Michal Hocko
> SUSE Labs


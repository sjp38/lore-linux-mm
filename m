Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A45AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 22:36:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 212912148D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 22:36:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 212912148D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 904E58E0003; Mon, 11 Mar 2019 18:36:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B27D8E0002; Mon, 11 Mar 2019 18:36:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A1738E0003; Mon, 11 Mar 2019 18:36:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0B18E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:36:39 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e5so668249pfi.23
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:36:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FTSLkO2dt0jTP41e0HX+zZNoDtNdiga3jBAnHIfBWR8=;
        b=OPNggwxoQZiHjM8N/q+u3Z6+uY3kpqyIuiKBFfFg9ys8wvmibLHUxXav8YJbPAVBI/
         anWSwMXQN4Xrv14vZdDIYlpnKUQHZx6X25PytzfrvDQul90sgDcV0kvcSk3ryG1CZdKX
         GaWeOaAfaN8nrJ8EIxS3s26Lwitx0r0w+GLu1dyTDn60eiX6DJHES3oPZF6TrHkaZlpC
         x+caQ3FnPFu+P6Wa7Vgxck7r+txw5cOYzlr2m2b3K8LDTQoVDLqkfSy+O2pPyW15gzsZ
         MRmtHLV6SjD9NcbH/69ai0goc+4yGeVVgMWg2M9UpZdrULNtIkyaP4L2A3dnY6U457OO
         vYkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAWejioa3S6JbXJU7Y9IVUrarCXKUcuzIM6Eb+djS8REbrHguOdV
	B1HYQhjp1CK9b/QfEPPgyCQpRt55MEZ/R7bkCArtFn12KNDZFZ+b0rJSnpLGwwFn+bHgLPNPREM
	DwMEkn7yXLeHGhziQk8EBYwUuafd9R5hSazwOru72lA4Ks9zOZ42Qk1IoRMWd/EknPHQSvptP+4
	ebqI1VwxTJml/Vz56hTo7KVVhOAtq9czEsU0UfaWfDmEPtoGrdXRi5K+yBQdppMSJQeVLwPCuNS
	xG8uGycSy+7Oj+DMPACmYKbV89AADT8IaxMh9VbU6C5XGRaT1gWeN1lnG0/Nuf6QsFqP3r2/MXG
	kLLDy+CbZVOEmiUR4rI4O2/4NJx5I0fq8X4ap6m8/ZK/6pIr+o2j+qUfJT+8mzajLGu98XVMXA=
	=
X-Received: by 2002:a63:1c02:: with SMTP id c2mr32417210pgc.351.1552343798830;
        Mon, 11 Mar 2019 15:36:38 -0700 (PDT)
X-Received: by 2002:a63:1c02:: with SMTP id c2mr32417160pgc.351.1552343797905;
        Mon, 11 Mar 2019 15:36:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552343797; cv=none;
        d=google.com; s=arc-20160816;
        b=dGOHjpIkBQheJeD6Qsu7mybyHML6qOiz7LQWzDgp4mRN7pGHAfS6tfSpb+YWcmjtjN
         eBkKvtZ/wTwItvRQY81nrbEs31zAeu1z/QHVSzL7g1EtKtR4T6zRnBS0xbs4NYjc3/y0
         CPOf2Tq0rmEQdJEKkLU6JrETcloLDasBm/sZxoNgf3i7ZdtzIVeOU2tDKifH6DiQoJCz
         xEmJp54Inpl8J0x97eeA18S6SMQFFiwEgRKw2brYYTX7oNH/CZi6s+zB3+wNDMX0mCgH
         wggctQIg8+Md5KOSY7tkftJtf0ONWxD0XB7NYtLUCSwg7MFCODiJUmt63Y6tkVh7oJHd
         MuCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FTSLkO2dt0jTP41e0HX+zZNoDtNdiga3jBAnHIfBWR8=;
        b=DSZ/axKhlgZxqEhfd51cGE7yTEPVwMDSQak/7/Hw8+UnvsvYlwoNRMUtLsrVW7uNPs
         sDWujgS2OXVjywJBa2lopAMB2EyuQeOaEPGtGz287Qr4dV7VU+GqE64Ym944/RB631MX
         X3ztalJD1GMpt3xvLYXL2QDCoFzJAWkrs9djypF773YxKNsCPdaPxwEPHC98P9d2Ionh
         z6ijveGC82YuigExiQiHBRKJjdRKtqfzhzOI+EgvdOvQeh4AGS5gbOWCLyhT9/jOgJ9X
         ukRI2aJbYjPt6eZxcpNX8eKHAjbCIBgoG0cJCDR+LGe50x2pm/GQT+Nzzy8y3hbpAHwD
         HuPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g135sor11157245pfb.0.2019.03.11.15.36.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 15:36:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqwtCMMAgm1ExGxRZdQlC7xQXFp1fcMVya1tiDe1OLHW4XIgMQjZPtO8FWjJfPY2Gx+joy0m+g==
X-Received: by 2002:a62:2ad1:: with SMTP id q200mr34726914pfq.34.1552343796423;
        Mon, 11 Mar 2019 15:36:36 -0700 (PDT)
Received: from sultan-box.localdomain (campus-061-148.ucdavis.edu. [168.150.61.148])
        by smtp.gmail.com with ESMTPSA id g67sm16424983pfg.13.2019.03.11.15.36.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 15:36:35 -0700 (PDT)
Date: Mon, 11 Mar 2019 15:36:31 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190311223631.GA872@sultan-box.localdomain>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 03:15:35PM -0700, Suren Baghdasaryan wrote:
> This what LMKD currently is - a userspace RT process.
> My point was that this page allocation queue that you implemented
> can't be implemented in userspace, at least not without extensive
> communication with kernel.

Oh, that's easy to address. My page allocation queue and the decision on when to
kill a process are orthogonal. In fact, the page allocation queue could be
touched up a bit to factor in the issues Michal mentioned, and it can be
implemented as an improvement to the existing OOM killer. The point of it is
just to ensure that page allocation requests that have gone OOM are given
priority over other allocation requests when free pages start to trickle in.

Userspace doesn't need to know about the page allocation queue, and the queue is
not necessary to implement the method of determining when to kill processes that
I've proposed. It's an optimization, not a necessity.

Thanks,
Sultan


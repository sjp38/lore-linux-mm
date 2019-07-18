Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A867C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:43:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1A17208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:43:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1A17208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F2566B0003; Thu, 18 Jul 2019 17:43:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A1F66B0006; Thu, 18 Jul 2019 17:43:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 391738E0001; Thu, 18 Jul 2019 17:43:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E2A966B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 17:43:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n3so20771834edr.8
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 14:43:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FFswUhx13JDZbY99owTeFGUc0SM/6zwBQpbbGib2DEE=;
        b=bZ+OYFX9C58xihDbBHjFExIej3qabQZwlTivN/l74nugakwJNA14582NjsDcsIm+ml
         Z72ntbXx+OYlJPMXqNMNfRO+UQV4moIRkeSDg5KGlC+9vyH50jnb5+YCFlUh1HCGe+hN
         NnXTCS3Y0vlI9RqlGhzQHGISHc2dOK3vMPZOUMM3AU9//UDmEwX440q1/TLODsB2oXTt
         1dFlQdXgblWJoOO7YqdawlNh5yY82kpmQRqRow/mnD1xNkfJa2FlPSviwr81QTTRm9Mo
         j43x/tpAwi6rCzR0Ns575kKfw9Cy28tj8+0cyIW8h7UWS2LdivYJnViYvWTegu847BZ2
         8NCw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAWnPgSi0BwhrvSiBCkRfqpm4fdkH++SOtYYeyRRRH2rVT9oUL7u
	biZY3veW88rFgrb5jM2tOYrca7pHD2swmruyj/+XHO9RJc+j45IXFFIb8pUlJxgFKaJFEBEpON8
	2KfbqCT/XYYSQavHphQooSPVCSndqHJaOmzS3A5WlJv0xY9UozHoJakhwFya/sa0=
X-Received: by 2002:a17:907:20ed:: with SMTP id rh13mr38232797ejb.34.1563486222395;
        Thu, 18 Jul 2019 14:43:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzag/Wa6Jyc86WoMvLfDZSkiEi5HlSuX4K/yl1XBMl0J6KdkxdWwznZ1KQ4XpcPfOSMd5fT
X-Received: by 2002:a17:907:20ed:: with SMTP id rh13mr38232758ejb.34.1563486221382;
        Thu, 18 Jul 2019 14:43:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563486221; cv=none;
        d=google.com; s=arc-20160816;
        b=d4/LUlkkoLZ2YGbgOWc6V+BBm5OEbAwvXZoOmIyU2sZvKI5XQsSYOjIv6Ci2b03cSV
         jzERU0R1d0w9OHll/BiMqhJIpNXD3eEN5mipzQDG8TOo7d6FvrR48mlKPPsyv0MvP4Gt
         aBWWHILRj3lseCIr1Iw+5tyQukAaillmdnNVZKVZQknofEKddf9ur6XdtskNsXORD8Iz
         Ks7nGgizZhOo5caFijUWX+4WPKhkQVWDzDfJBLXIT+IORrVdYcCPzG/Wg8rkFwp/QcgI
         RMkyBXlahyjbyRMRsvlUBEonfj87X25U7+lt/VWOimvwkvwUBeRHGVBiXrjcYyiszYap
         r9JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=FFswUhx13JDZbY99owTeFGUc0SM/6zwBQpbbGib2DEE=;
        b=Z7g8l/lLLB1pkjZbLVBZi/erSJ7MLlPqibfmxgu/0A8lgrvCPZlcRHDW6VqR6ho5jR
         781zuAokDWezb6p/tT0fGu/1u3K5RhSf1YzP99IZbAvGE2mCyzwVdKzL2cJpZmRYitEL
         xD8ANdq0R94kx49W25so1gOyPPGyyiiTyVHzWyaH/5AkCE17/YAVmpDBdU2b+VqyLFFW
         d8JoDxEyttNlJ8ZhYSRe7zlfQD2qdxVQf7sOR9t9Swg/Lc/Fa2AU4/naPMacCAUjycaA
         LLVNK6YrHcDgF/20JV5JmPHIE4bGZ/Muz+6US5ZNqzhbJlYZroeVssJiDo7dFl+hyURp
         Byog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id k21si12583ejx.155.2019.07.18.14.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 14:43:41 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id AE4B315285AD7;
	Thu, 18 Jul 2019 14:43:38 -0700 (PDT)
Date: Thu, 18 Jul 2019 14:43:36 -0700 (PDT)
Message-Id: <20190718.144336.350349509076783997.davem@davemloft.net>
To: torvalds@linux-foundation.org
Cc: ldv@altlinux.org, hch@lst.de, khalid.aziz@oracle.com,
 akpm@linux-foundation.org, matorola@gmail.com, sparclinux@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
From: David Miller <davem@davemloft.net>
In-Reply-To: <CAHk-=wgjmt2i37nn9v+nGC0m8-DdLBMEs=NC=TV-u+9XAzA61g@mail.gmail.com>
References: <CAHk-=whj_+tYSRcDsw7mDGrkmyU9tAk-a53XK271wYtDqYRzig@mail.gmail.com>
	<20190717233031.GB30369@altlinux.org>
	<CAHk-=wgjmt2i37nn9v+nGC0m8-DdLBMEs=NC=TV-u+9XAzA61g@mail.gmail.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Thu, 18 Jul 2019 14:43:39 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Jul 2019 17:17:16 -0700

> From the oops, I assume that the problem is that get_user_pages_fast()
> returned an invalid page, causing the bad access later in
> get_futex_key().

That's correct.  It's the first deref of page that oops's.


> But that's odd too, considering that get_user_pages_fast() had
> already accessed the page (both for looking up the head, and for
> then doing things like SetPageReferenced(page)).

Even the huge page cases all do that dereference as well, so it is
indeed a mystery how the pointer works inside of get_user_pages_fast()
but becomes garbage in the caller.

This page pointer sits on the stack, so maybe something stores garbage
there meanwhile.  Maybe the issue is even compiler dependent.

I'll keep looking over the changes made here for clues.


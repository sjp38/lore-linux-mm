Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 234E1C43381
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 21:27:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF6FE20657
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 21:27:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF6FE20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A0098E0009; Sun, 10 Mar 2019 17:27:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24F848E0002; Sun, 10 Mar 2019 17:27:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CA7E8E0009; Sun, 10 Mar 2019 17:27:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC0978E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 17:27:01 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id u132so1512752oif.6
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 14:27:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4u1OcIKNyiAZm/99ALlppfHz2fZU/SI9CMTqcRRtHzs=;
        b=q+Fgm0RSi+sqhZg/dBj9FcS1lvH6UdlG1pv+w3DexMMtErHzEXj5/y7yZ441jMh3Sk
         a0uIlQ3rgIRvMefAcTYod8ZEgJhNb7NGwBtVPlNbYoB2nw15KhWDoiLhZrs03AQc0/qT
         jeFDFfwj7rXuz5DiLIO/9heEHoeaZPeOrajPQvH904p+GWbotvj4Nda4R7osRXuj6HoE
         YbzVJWBnTKTXsQXkQSS987XkPmFTNvHFctIM396IpU+Fa7JjYhA2o5zSVm8sbAiCHgQB
         GLY+29UfNECYYjFoDCux+G2xyA55hY9I8gYAJsjq1go6fSL9PHMbxCXrzXf07FSTpIlf
         +Pfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAXT2gKRuPj4AqwJhqVpkLC9RFZs0y4QRIk0wJ6OctTJti8WN6Ou
	/DjonD8amIK4OdVh1RFTADYzQimx3n2GCo0/LWyOzepvbaMlrUw2/u9CNyGmH1xC4CloTP/diBY
	VTijLMT3rwi8bC2DBTii/Xqy1sqNYTCmSpQGERSvjJaL7LwUR+eYkipkiqYkmwo2rH4SQxsgds4
	1G1MGskE22MqoX4qIlH9crqyasgpq9VvzMPEszWUl4/ZNWzfEF9F6JuaGJ7dqUwVC+W6q7fJcz7
	XC9OBX4JzI6Tl5JW0zLbH7nI3frliZZEY8BbIzdVNnkcWcpcePY24cU7kYkO92hL5WBwl35pEtX
	fKZZTL5lXxFbW2Y5JRnPga1uhVgvw+IqUfblsOkosKPLka+RGK2daK+toP+WewEFoFMtqVDvfQ=
	=
X-Received: by 2002:a9d:7d03:: with SMTP id v3mr4043383otn.93.1552253221549;
        Sun, 10 Mar 2019 14:27:01 -0700 (PDT)
X-Received: by 2002:a9d:7d03:: with SMTP id v3mr4043355otn.93.1552253220617;
        Sun, 10 Mar 2019 14:27:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552253220; cv=none;
        d=google.com; s=arc-20160816;
        b=SzUS13rY2afBUQ33s0mX02T4jacpKBhsXM/ZQMzrBFvRqfX9DpgFWJfNjyauUe+CIb
         hwGVWdYwjinhkjVRH0quhH/uMH0Z1xHw4tseLZtm5DP1A4FAhCl9IRtazlCWPa06SQBh
         +g7b3Xwp5k4zUiKiGXeUk+SrwHCdDu5OVTVF3OaTEIBql9ykLDo1uKBU4kcHUma4qd4C
         pv+qaZStbjdOoIQL6rAI6mm/amlkibbP8uMZgCTp+3ms/vej/H10G4Y5D8aIHaMnbYhp
         J1X5uxB7Tx4L+2Ke5q7XBpRn9MzwXKnMhbrE8pfPDkiUf1XrEW21t+rlEjvG2QiwBUV7
         vKWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4u1OcIKNyiAZm/99ALlppfHz2fZU/SI9CMTqcRRtHzs=;
        b=LvNIty/o1LZtlxKvEjbTV0MNAdsIuZsk6yGlJOJmYIzHB8WjpuaRk7wNW6U8hc/2P+
         ysxtA0Hh49b9Y1Havi47mrDtlhJIyZ+0+SAz6a+RvXEL/z24/C2q9m/SIfBTGP3oHeeq
         rE9uppQEtrVBoZJSJrtUNAc67dUvbF4MIFdTVGnTDedcT20W3KVeYeJasCeTMkwaKgvY
         fr5hY4jsclY/ImsxVvEKp1XuT2fBlFcWw6Mak/z8ttdiQvDM+0dtNpHGR+QMJHTuQCRm
         muFuxkgoQIOKKhx2rA7rNk669z4nIcKoLC7FpIqSKaVcn5yd5lRFT9XoOZ9HE2WYAquw
         SJSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l144sor1683156oig.160.2019.03.10.14.27.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Mar 2019 14:27:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqxjcCjnFU3RfO/1hwx3pHB+Yb48/5V7ITu0oaflmB41chl6Xwpbn9jCqKcryoCjKc9W4RYkzQ==
X-Received: by 2002:aca:51cb:: with SMTP id f194mr14997826oib.6.1552253220128;
        Sun, 10 Mar 2019 14:27:00 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id j21sm1626192otr.28.2019.03.10.14.26.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Mar 2019 14:26:59 -0700 (PDT)
Date: Sun, 10 Mar 2019 14:26:55 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org,
	devel@driverdev.osuosl.org, linux-mm@kvack.org,
	Suren Baghdasaryan <surenb@google.com>,
	Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190310212655.GA30695@sultan-box.localdomain>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190310210335.GA5504@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190310210335.GA5504@kroah.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 10, 2019 at 10:03:35PM +0100, Greg Kroah-Hartman wrote:
> On Sun, Mar 10, 2019 at 01:34:03PM -0700, Sultan Alsawaf wrote:
> > From: Sultan Alsawaf <sultan@kerneltoast.com>
> > 
> > This is a complete low memory killer solution for Android that is small
> > and simple. It kills the largest, least-important processes it can find
> > whenever a page allocation has completely failed (right after direct
> > reclaim). Processes are killed according to the priorities that Android
> > gives them, so that the least important processes are always killed
> > first. Killing larger processes is preferred in order to free the most
> > memory possible in one go.
> > 
> > Simple LMK is integrated deeply into the page allocator in order to
> > catch exactly when a page allocation fails and exactly when a page is
> > freed. Failed page allocations that have invoked Simple LMK are placed
> > on a queue and wait for Simple LMK to satisfy them. When a page is about
> > to be freed, the failed page allocations are given priority over normal
> > page allocations by Simple LMK to see if they can immediately use the
> > freed page.
> > 
> > Additionally, processes are continuously killed by failed small-order
> > page allocations until they are satisfied.
> > 
> > Signed-off-by: Sultan Alsawaf <sultan@kerneltoast.com>
> 
> Wait, why?  We just removed the in-kernel android memory killer, we
> don't want to add another one back again, right?  Android Go devices
> work just fine with the userspace memory killer code, and those are "low
> memory" by design.
> 
> Why do we need kernel code here at all?
> 
> thanks,
> 
> greg k-h

Hi Greg,

Thanks for replying. It has not been my experience and the experience of many
others that Android's userspace low memory memory killer works "just fine." On
my Pixel 3 XL with a meager 4GB of memory, the userspace killer has had issues
with killing too many processes, which has resulted in a noticeably poor user
experience for all Pixel owners. From the looks of lmkd on the master branch,
there still isn't really any definitive solution for this, aside from a 100ms
delay in between process kills.

I think that the userspace low memory killer is more complex than necessary,
especially since in the kernel we can detect exactly when we run out of memory
and react far more quickly than any userspace daemon.

The original reasoning behind why the old kernel low memory killer was removed
is also a bit vague to me. It just seemed to be abandonware, and all of a sudden
a userspace daemon was touted as the solution.

This driver is like an Android-flavored version of the kernel's oom killer, and
has proven quite effective for me on my Pixel. Processes are killed exactly when
a page allocation fails, so memory use is maximized. There is no complexity to
try and estimate how full memory is either.

Thanks,
Sultan


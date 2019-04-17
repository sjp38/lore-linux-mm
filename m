Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45C48C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:26:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5BE72173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:26:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KK6QowY/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5BE72173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 748AF6B0003; Wed, 17 Apr 2019 08:26:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F8916B0006; Wed, 17 Apr 2019 08:26:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C1AC6B0007; Wed, 17 Apr 2019 08:26:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0993E6B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:26:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f7so12719409edi.3
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:26:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3b2uZe+gBUttgntQPw/pLBUTjB9i8teUhwUDcx5nvkU=;
        b=nUH2EF2AsQYb1PPyFx5IOcw/Ba216CogvfomJwL8M6SyVNCE+yt6BktEXL9BqswCDi
         ffbYszthEZKo8CfRxV2nhaKe89rEhYsxi/VUuqvSeW2PSnpffBS5wVvg+HRKdXJHiAEf
         TkS5M4fHWT6AJzHbkuPBQhYJrlbtJM01YfoAa9B+gbikluyYAlbwf6unvzQJ8fPRB82M
         ZbTSgDQiom9lCsEjgDVcl5+4yCDoJ2xTb0R34XjuePihZ75rJf4cWBS6Ei3NFB5Evh3z
         zQRmBIwYfp47M/FRtmD+/PV8ZhdiC/Gux9pRvrs1GLJLTYuBj3ium2sHsQa+dP2IKhbC
         qO9A==
X-Gm-Message-State: APjAAAXvXZifJf7nIItszgfzfCdthk2LzDTjqrvBNfilkUKKDsNg8QkU
	lE6DiZjzmZuZPWF/PGxbV77l7kWFspW5WXML5iyD95sTVnFTWhYJvUPohf50i+6BjODx940+gXj
	C2AiRGL06kr0WAHmF3GMIUKtOcgWMEC+rXGLyP3SF9sduHz80MeMaIR0xTaqxuR1+8Q==
X-Received: by 2002:a50:ad3a:: with SMTP id y55mr16959850edc.220.1555503994505;
        Wed, 17 Apr 2019 05:26:34 -0700 (PDT)
X-Received: by 2002:a50:ad3a:: with SMTP id y55mr16959785edc.220.1555503993538;
        Wed, 17 Apr 2019 05:26:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555503993; cv=none;
        d=google.com; s=arc-20160816;
        b=jx9XRhzGx7pdqelK8MLjeU3zjCDHH5XGjUC7SUe1ypW8bqMpPh15svqtonmSrDUTEC
         duLp8ZDaJQUXzu6D57cSCNkmL/OigpKKpWPI6pbSi/Cv2hD4u56c+ko49fslfg4f/EEZ
         ZvjYXtVP3LANRz+JcjVdRh2MTwwaNQM6uYrsLn14OIryKkXhydgH9tskSgYmEStyGYNn
         Ui/2lP+odbG3mxqR4A5oE60nOxQ/dAU/FMIYju5QQhRX+exHvNHOba3+5FdxEALqi8lj
         cY4hef3OJaL8BfCAVPTX0p9WNOGsPQaQBN6u56gPm8Bp2g3QY5rBaCpYmuymj4i7oTZx
         Zomg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3b2uZe+gBUttgntQPw/pLBUTjB9i8teUhwUDcx5nvkU=;
        b=S2TfKmRJG5/buw6r+VpP5WwnztgI8NwlDVm38TgaC/uTbthNyvE6KY1A16skglywKz
         d6R4D61AzWGjkCVi9Y6XKI5nl7XyAsyMyK+vTy8JzjhtZMbeJUL4VRcFk1OxWZ4b0wVV
         J3y/5h/vcAXHbN2KFwW7f86l2fopJWdhDPf0e7A9ZGFJfENSRzuy03aYOEu9+mWvUE6P
         qMUjaS5MCc3johaQFsJFq1OMlzeg/tSrvq/52d+Ae00UvURnulEC8yiLqaiC1ZtGVQha
         wA4fX1Rt37qcSiCLIQzOxmsrd7fv+Ey6T0dXX7pKzAztJIJL4j8p1QE3eZL3F/l/gYuI
         xgQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="KK6QowY/";
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e9sor11807050eji.55.2019.04.17.05.26.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 05:26:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="KK6QowY/";
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3b2uZe+gBUttgntQPw/pLBUTjB9i8teUhwUDcx5nvkU=;
        b=KK6QowY/D/XJnf34A9ek6IxXn6rQC/5Kq9psSCHLgXaFoDYONhAxg7uNNIS3wIeseQ
         dernRPR92l9iqju3XdqqdFaOvjahmacxMyrtT8stUEqcJOIBMNOcxO80y2Ze2hqITnqT
         ZD+Q7LnT5ovRNk24Cuaq0BKEaMrx8qnTqwPYm0ejr6FzX2bHTsoS+qMldVJ3n/wKugVX
         H/aXvxrJF90ZD1xcFEeaI9rSano/K/P7kbB6LIicMTQf7D1UnMyFYQHKT0LSOyo/rnDz
         P/v2yxpVYnFjQQJSwspEOytvbCU5af/7wEV4SY5QA/w+6h/7Hir7GSaWdrlmPh0AEX8k
         idvQ==
X-Google-Smtp-Source: APXvYqx0Wip+oc7EhgVnQowF25cIy00yB1LazPefnMEy3YkhKtVYai8VkPbsXXR6VZH7ei3AgU3Uvmxd+7WGlxnPcCg=
X-Received: by 2002:a17:906:1119:: with SMTP id h25mr26182051eja.233.1555503993060;
 Wed, 17 Apr 2019 05:26:33 -0700 (PDT)
MIME-Version: 1.0
References: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
 <CAGWkznFCy-Fm1WObEk77shPGALWhn5dWS3ZLXY77+q_4Yp6bAQ@mail.gmail.com>
 <CAGWkznEzRB2RPQEK5+4EYB73UYGMRbNNmMH-FyQqT2_en_q1+g@mail.gmail.com>
 <20190417110615.GC5878@dhcp22.suse.cz> <CAGWkznH6MjCkKeAO_1jJ07Ze2E3KHem0aNZ_Vwf080Yg-4Ujbw@mail.gmail.com>
 <20190417114621.GF5878@dhcp22.suse.cz>
In-Reply-To: <20190417114621.GF5878@dhcp22.suse.cz>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Wed, 17 Apr 2019 20:26:22 +0800
Message-ID: <CAGWkznHgc68AHOs2WNPARmwMMKazuKXL1R4VsPD_jwtzQeVK_Q@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/workingset : judge file page activity via timestamp
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, 
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>, Roman Gushchin <guro@fb.com>, 
	Jeff Layton <jlayton@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

repost the feedback by under Johannes's comment
When something like a higher-order allocation drops a large number of
file pages, it's *intentional* that the pages that were evicted before
them become less valuable and less likely to be activated on refault.
There is a finite amount of in-memory LRU space and the pages that
have been evicted the most recently have precedence because they have
the highest proven access frequency.
[HZY]: Yes. I do agree with you about the original thought of
sacrificing long distance access pages when huge memory demands arise.
The problem is what is the criteria of selecting the page, which you
can find from what I comment in the patch, that is, some pages have
long refault_distance while having a very short access time in
between.

Of course, when a large amount of the cache that was pushed out in
between is not re-used again, and don't claim their space in memory,
it would be great if we could then activate the older pages that *are*
re-used again in their stead.But that would require us being able to
look into the future. When an old page refaults, we don't know if a
younger page is still going to refault with a shorter refault distance
or not. If it won't, then we were right to activate it. If it will
refault, then we put something on the active list whose reuse
frequency is too low to be able to fit into memory, and we thrash the
hottest pages in the system.
[HZY]: We do NOT use the absolute timestamp when page refaulting to
indicate young or old of the page and thus to decide the position of
LRU. The criteria which i use is to comparing the "time duration of
the page's out of cache" and "the active files shrinking time by
dividing average refault ratio". I inherite the concept of deeming
ACTIVE file as deficit of INACTIVE files, but use time to avoid the
scenario as suggested in patch's [1].

As Matthew says, you are fairly randomly making refault activations
more aggressive (especially with that timestamp unpacking bug), and
while that expectedly boosts workload transition / startup, it comes
at the cost of disrupting stable states because you can flood a very
active in-ram workingset with completely cold cache pages simply
because they refault uniformly wrt each other.
[HZY]: I analysis the log got from trace_printk, what we activate have
proven record of long refault distance but very short refault time.

On Wed, Apr 17, 2019 at 7:46 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 17-04-19 19:36:21, Zhaoyang Huang wrote:
> > sorry for the confusion. What I mean is the basic idea doesn't change
> > as replacing the refault criteria from refault_distance to timestamp.
> > But the detailed implementation changed a lot, including fix bugs,
> > update the way of packing the timestamp, 32bit/64bit differentiation
> > etc. So it makes sense for starting a new context.
>
> Not really. My take away from the previous discussion is that Johannes
> has questioned the timestamping approach itself. I wasn't following very
> closely so I might be wrong here but if that is really the case then it
> doesn't make much sense to improve the implementation if there is no
> consensus on the approach itself.
>
> --
> Michal Hocko
> SUSE Labs


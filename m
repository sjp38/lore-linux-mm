Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF16EC3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:43:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B35AE21883
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:43:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="CDKSoL3y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B35AE21883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 519026B0003; Wed,  4 Sep 2019 16:43:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CA7B6B0006; Wed,  4 Sep 2019 16:43:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E0C26B0007; Wed,  4 Sep 2019 16:43:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0158.hostedemail.com [216.40.44.158])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1546B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 16:43:48 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A809E181AC9AE
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:43:47 +0000 (UTC)
X-FDA: 75898414494.30.touch75_785ead6531b39
X-HE-Tag: touch75_785ead6531b39
X-Filterd-Recvd-Size: 4091
Received: from mail-lf1-f68.google.com (mail-lf1-f68.google.com [209.85.167.68])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:43:47 +0000 (UTC)
Received: by mail-lf1-f68.google.com with SMTP id u13so85368lfm.9
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 13:43:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YiYO9VWWpRx7v6PM8o2EGGH10D6630klg63G2tZstsw=;
        b=CDKSoL3y0gWDvz+9iXrm8ACq+PKIk4ww39yv5fj7+QG8AIlQEFQdFDHCMmlHDeSux1
         WIGXEeanbtpped938Baz6GkN4m/db3Ltfk6ySLhsaFUavZIkhyTfz5limM1z/Fx5YSyN
         jQ4gK+rRnsHjNSTKgxuK6NxXCkcBIYr8FcoUU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=YiYO9VWWpRx7v6PM8o2EGGH10D6630klg63G2tZstsw=;
        b=ZFeuZ6ozF483buKy53o9pGdNBQH4qycIWLZy4uS08tY1lTjLse15MULqlShAgxtJPb
         L4vFF4MI2kSwlWbWy9+tmVoqH0+qLcxZv/AFu02ExTPIUiwIN7j6btPQhySqUR/S+sYM
         wf5z7T7Gx7cdWWnrQrt+uVD+eu1BOKPzYJJt1fKTskbJbCzrjoiBR3aQewx4HMVG8LFF
         QVO+CJbOOlVFqDcscjEYmxV+BVoGwbFaVgSnvM0B6uWqM1Iauyf+D8YoHXOaq6sateGT
         mFZQTKj4SPibiGJw/f/wP7Qj+avDuC6OJLYh5bL2hDQY3x3XgQ7P2nOtJhcTAmHbBj8k
         fm+w==
X-Gm-Message-State: APjAAAUrDrAyIdbZR8uPt5+NsbEwK737MSCXnE/2qRuVLvVbneEZHEB1
	wALhajXFVfjaIG/FQJ2QiLj3FWjjBro=
X-Google-Smtp-Source: APXvYqzO8Zqae/hN/zJlYZf2Wjxo6VPihlkQErYrnnxpiW3q9LMksH0ezRd8R3SzMdv/CaWGlrckbA==
X-Received: by 2002:a19:f806:: with SMTP id a6mr26968lff.151.1567629824520;
        Wed, 04 Sep 2019 13:43:44 -0700 (PDT)
Received: from mail-lf1-f46.google.com (mail-lf1-f46.google.com. [209.85.167.46])
        by smtp.gmail.com with ESMTPSA id v7sm1218964lfd.55.2019.09.04.13.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 04 Sep 2019 13:43:43 -0700 (PDT)
Received: by mail-lf1-f46.google.com with SMTP id z21so122654lfe.1
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 13:43:42 -0700 (PDT)
X-Received: by 2002:a19:7d55:: with SMTP id y82mr55521lfc.106.1567629822677;
 Wed, 04 Sep 2019 13:43:42 -0700 (PDT)
MIME-Version: 1.0
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 4 Sep 2019 13:43:26 -0700
X-Gmail-Original-Message-ID: <CAHk-=wjmF_MGe5sBDmQB1WGpr+QFWkqboHpL37JYB5WgnG8nMA@mail.gmail.com>
Message-ID: <CAHk-=wjmF_MGe5sBDmQB1WGpr+QFWkqboHpL37JYB5WgnG8nMA@mail.gmail.com>
Subject: Re: [patch for-5.3 0/4] revert immediate fallback to remote hugepages
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, 
	"Kirill A. Shutemov" <kirill@shutemov.name>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 4, 2019 at 12:54 PM David Rientjes <rientjes@google.com> wrote:
>
> This series reverts those reverts and attempts to propose a more sane
> default allocation strategy specifically for hugepages.  Andrea
> acknowledges this is likely to fix the swap storms that he originally
> reported that resulted in the patches that removed __GFP_THISNODE from
> hugepage allocations.

There's no way we can try this for 5.3 even if looks ok. This is
"let's try this during the 5.4 merge window" material, and see how it
works.

But I'd love affected people to test this all on their loads and post
numbers, so that we have actual numbers for this series when we do try
to merge it.

            Linus


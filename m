Return-Path: <SRS0=fDmo=QD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44A40C282CC
	for <linux-mm@archiver.kernel.org>; Sun, 27 Jan 2019 22:35:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E440220882
	for <linux-mm@archiver.kernel.org>; Sun, 27 Jan 2019 22:35:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E440220882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CC4F8E0105; Sun, 27 Jan 2019 17:35:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37D548E0104; Sun, 27 Jan 2019 17:35:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26C8D8E0105; Sun, 27 Jan 2019 17:35:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCBC88E0104
	for <linux-mm@kvack.org>; Sun, 27 Jan 2019 17:35:46 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so5840071edz.15
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 14:35:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=HIxvv1F/4nwQblfjJiBGcm4fcWeH/jFpMTVF33K+7nE=;
        b=b263PvI/fPYt/rGspR5VDl9N3dsgGb83f8SfQb91rk2zJyrTmjeT7Kuag78cot6lgA
         DLRlTrhmUasY21m2/ITICJ5KYg0wv4DfsOfhn0NS0O/gnGZDgAmupnF8ttBV+1ajP8N9
         XNazjptxIOkoSIzIFfy+74vzJgEOZwsCmsblN17pW87SptMVmvQoKRBMdZfhkte+d/b4
         eKQ1Y4Gl0CR0eDaUzreWNrSaJ+Lq7s/uLMWiv1tDx2OvaWWMySnGDyLzHbp1eQrIFOW/
         NrJ4pHEPLNyDpCsFlWxS/lX87DnPd1E2BrEMu/BiWGbEWXUguSpYdTSbncz68WZMt80g
         npOw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcA9vHLPvxfmjIZR3kbJ5WyJfjxsBshDRmWaO8QNwC5FSUzX4q7
	bamWPVuiPVcHbRgkuROfFLXfJxp7geyG2SsG5ZIFb+8D9oFZTnYoBR2lnDpEkQzSGyjif2icUHQ
	UBYvuGqpDeSGe5appHtrqZo8NqMG/IqHxVgw21v8VHv3RmQxIiLiJH2a93mYPzZg=
X-Received: by 2002:a05:6402:758:: with SMTP id p24mr19802914edy.92.1548628546286;
        Sun, 27 Jan 2019 14:35:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4papWpvH9/sKo+juH3KjL/lH/88+xY50WZ+UEabMg+O3nZpU6W7x+uS9OYXk3Yj4+eeSPv
X-Received: by 2002:a05:6402:758:: with SMTP id p24mr19802890edy.92.1548628545393;
        Sun, 27 Jan 2019 14:35:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548628545; cv=none;
        d=google.com; s=arc-20160816;
        b=vxpu+0cQJSnohWXvjq0hoTgf2+MbkSOyj5K0cx7YamfDHBVFnvKi5bNvv3lSUo68gn
         fiGt8aPKrBaEvWeX3RVOKeic680N4uFOr9fZiFllmPjvwaoeuNh4LdUa4azRw7T17AHZ
         xKLsFoFfPyIl9J6fOIpwKM2g7h5r5ZcRQfjpxvSXP6qajPXJCIBuHOxBzmb1IefurTYq
         6AkO0YY5BQWUPE1TnVC2DGIR5BzC8mpazlOtBpeIVjk/yVj2cXvMs1B7Ooz+q+COGqZb
         3ZS75ffv/LtWMygw3cAWYTaU1Lv+pDc5wqO1TyOHrUX6A57QhgyDi77S8Z68E13BiQjD
         BPdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=HIxvv1F/4nwQblfjJiBGcm4fcWeH/jFpMTVF33K+7nE=;
        b=wiFl9WHDKINFa+8p923nejc5gc0Z3eBT9o/sw7NHJe5WyjjcD9Pfd3PI6YxAC1ypmt
         qyGhCD14h+Wr3FQCEh6bv+QM2w0Uf7Q7QFqfp3dcpi1FUj1Hkb58rCNEuiMNmBxN7JVu
         5smTiA4W6lbfrBmIRVCnuwo5gfO9xgc+TVwBSGcLXrJeIM2niardc16g4vFFR41OVfj7
         8Ka608dpWQ0OfP1+cuqLEyBw/lK/Jn9CCR/C9LkJFxPm2goMCrY+yJdUgpbEMzMlSCDM
         m8RiPzvVgqILbZA0d+p6ptflrZ1WLPCkhNp+vgIh9cbIifr7qCT2iV0b2Z0t9002Rwm+
         D7Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y25si728311edv.448.2019.01.27.14.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Jan 2019 14:35:45 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5DB8FAE9D;
	Sun, 27 Jan 2019 22:35:44 +0000 (UTC)
Date: Sun, 27 Jan 2019 23:35:42 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Dominique Martinet <asmadeus@codewreck.org>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, 
    Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, 
    Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <nycvar.YFH.7.76.1901241523500.6626@cbobk.fhfr.pm>
Message-ID: <nycvar.YFH.7.76.1901272335040.6626@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com> <20190124002455.GA23181@nautica> <20190124124501.GA18012@nautica> <nycvar.YFH.7.76.1901241523500.6626@cbobk.fhfr.pm>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190127223542.La0izxg9x8E8Cu88jpLkhMrX-bazk90QAJWXm3z5ZNg@z>

On Thu, 24 Jan 2019, Jiri Kosina wrote:

> > Jiri, you've offered resubmitting the last two patches properly, can you 
> > incorporate this change or should I just send this directly? (I'd take 
> > most of your commit message and add your name somewhere)
> 
> I've been running some basic smoke testing with the kernel from
> 
> 	https://git.kernel.org/pub/scm/linux/kernel/git/jikos/jikos.git/log/?h=pagecache-sidechannel-v2
> 
> (attaching the respective two patches to apply on top of latest Linus' 
> tree to this mail as well), and everything looks good so far.

So, any objections to aproaching it this way?

I've not been able to spot any obvious breakage so far with it.

Thanks,

-- 
Jiri Kosina
SUSE Labs


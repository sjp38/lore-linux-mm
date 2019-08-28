Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6FE4C3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 21:17:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78ACE2339E
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 21:17:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="WseL6QFZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78ACE2339E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F7586B0006; Wed, 28 Aug 2019 17:17:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 081606B0008; Wed, 28 Aug 2019 17:17:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8A916B000C; Wed, 28 Aug 2019 17:17:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0068.hostedemail.com [216.40.44.68])
	by kanga.kvack.org (Postfix) with ESMTP id BFE6E6B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 17:17:28 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 2ABD08243762
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 21:17:28 +0000 (UTC)
X-FDA: 75873097776.19.rod57_6f4494780f15
X-HE-Tag: rod57_6f4494780f15
X-Filterd-Recvd-Size: 4386
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 21:17:27 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id o9so2540013iom.3
        for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:17:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1Pid6vUuPUlJYXQ1gshe5GaMyymzgf1ptZw4JML3tNQ=;
        b=WseL6QFZVj5hjD4LSdeRDxgvi8R9OrWhijXgU4dVjGt1oetpvN2AyHUnm4zOKs8iqo
         at1k51orF9049/Ghe2jeEBeJmxckts5NjcvtT1cIG0yaAyYZEWumEgVeU71owQJjSuxV
         r+v1ZAVuEBOBRavO0JllTktHLYLN4aNtNFMaWm8dNulMO+VvauX+Kt+HVLPbDYhqEJlM
         1rW9s6pu2jiJxHyNKaOscZh63d6ouPB5aoh6Er2aGItp9wCPJ77A40bdtwAeyOjCFpKx
         LIeuQHiz5et647Kxo1j7BqaWjOzdldFmGfxT/0+FE94fDgJoz8xj/x1zdQGnq12nGCTB
         hjoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=1Pid6vUuPUlJYXQ1gshe5GaMyymzgf1ptZw4JML3tNQ=;
        b=FsDstK47IyUf/zOvA53/crUh2lwVONTW1wCihftH3l8ClNhkO8N7IfwyAzjMSeRcCc
         5uosdYbP5BPvXe/9g9auVJEMTUnHVKGLM0JFdBIqjBWGjFRCbnpKrAZ+ZDJpNxl/+sdS
         U3NwHu43xeViNy9NCp6vfvqT5szi7uTpP5pNLjepzvRPOgl3lgjbrzPR3FZf6RiSjvzp
         LNSFCbX4Y0yEEeH3j31b7D6PV6wKfDMFPTJdDXtZKCRJx59jc6K/TJUwRBojKRhKhuMg
         tHJ3gpo16CVLZucxZUznG+KZMTDVzXDhPw79kmitAo5yQ9xvbuOwVDynadDK//oBWKOY
         q30Q==
X-Gm-Message-State: APjAAAXu03f2eFXeiewlHQeRyQfoOP/OSRo6TtWzDlh7/2CIIuIz6dJO
	c6EPdCV2HEQS568IBCCADsgxlcSdkWJ+e04hi0miUA==
X-Google-Smtp-Source: APXvYqzVzRPzdAPeHNOQBlR1nvJV0H0d2CsA0hvt0BTy4EMMSJLTlGYVNwIrII+XDJqGKBCcN398iLPUM0AbEzlm8wE=
X-Received: by 2002:a6b:3ed4:: with SMTP id l203mr6931699ioa.275.1567027046855;
 Wed, 28 Aug 2019 14:17:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190826193638.6638-1-echron@arista.com> <20190827071523.GR7538@dhcp22.suse.cz>
 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
 <20190828065955.GB7386@dhcp22.suse.cz> <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
 <1567023536.5576.19.camel@lca.pw>
In-Reply-To: <1567023536.5576.19.camel@lca.pw>
From: Edward Chron <echron@arista.com>
Date: Wed, 28 Aug 2019 14:17:14 -0700
Message-ID: <CAM3twVQ_J77-yxg+cakUJy9-oZw+j-9xdunaAJdJdfZfCb5GSA@mail.gmail.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional information
To: Qian Cai <cai@lca.pw>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 1:18 PM Qian Cai <cai@lca.pw> wrote:
>
> On Wed, 2019-08-28 at 12:46 -0700, Edward Chron wrote:
> > But with the caveat that running a eBPF script that it isn't standard Linux
> > operating procedure, at this point in time any way will not be well
> > received in the data center.
>
> Can't you get your eBPF scripts into the BCC project? As far I can tell, the BCC
> has been included in several distros already, and then it will become a part of
> standard linux toolkits.
>
> >
> > Our belief is if you really think eBPF is the preferred mechanism
> > then move OOM reporting to an eBPF.
> > I mentioned this before but I will reiterate this here.
>
> On the other hand, it seems many people are happy with the simple kernel OOM
> report we have here. Not saying the current situation is perfect. On the top of
> that, some people are using kdump, and some people have resource monitoring to
> warn about potential memory overcommits before OOM kicks in etc.

Assuming you can implement your existing report in eBPF then those who like the
current output would still get the current output. Same with the patches we sent
upstream, nothing in the report changes by default. So no problems for those who
are happy, they'll still be happy.


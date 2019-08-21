Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E30F0C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 07:27:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A272D2332A
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 07:27:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VXGN3d0R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A272D2332A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F1D46B02A1; Wed, 21 Aug 2019 03:27:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A1556B02A2; Wed, 21 Aug 2019 03:27:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 290456B02A3; Wed, 21 Aug 2019 03:27:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0048.hostedemail.com [216.40.44.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF096B02A1
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 03:27:34 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AD1EE180AD805
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 07:27:33 +0000 (UTC)
X-FDA: 75845604786.04.table49_41f75a3b4fb23
X-HE-Tag: table49_41f75a3b4fb23
X-Filterd-Recvd-Size: 3952
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com [209.85.166.67])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 07:27:33 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id i22so2651952ioh.2
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:27:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8XLFvGowEZKAI917o3yISsFesY5lXtThplXY3LzU/gQ=;
        b=VXGN3d0R+9aF27+WfoXVf3MFzOG/XJij86fAqLjbOTut86tPlfD54+ANJj/RicMCm9
         ME1F9WX88CRbfVR86Leo6DXi7PBgJAdjC9FXDMn+pkVGLr6f9YDto10apVIKVZIfkISG
         +I/ozFviYNxgUgF0KEHWjFP2ah5NqLR6MkGNY9RcESfmtDVV5tU4PIL126oDZh/UycMJ
         gI1WYLv6/WAsve382lEIh/B7N8dzwP7niADuJxu2bmKz0Vyx8z4tNiJveRCDyK1rVfXC
         lDQ0phM565prSg4baOt6PiarU8+6Qdun8UCDCWU3AJ+d0LJiO/TaeAzQnFWE3rXnPGRO
         4SZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=8XLFvGowEZKAI917o3yISsFesY5lXtThplXY3LzU/gQ=;
        b=OOPoPSZXstSz6uZOmdLmw7mup7lsoGTn465PTBaQZUNf0iUhGPy+/3yajNQ99NbQTF
         S7TFLn3aqyisGWQtPzMOG461yGwmBhArcT+2yEgSfmkF6wRy6mrYTuak8hsFo89jyygr
         hOWec5jjMjLbHXoxEi67bTxt3g1ZZCDfYvN/vj41JcqtSb0wsC7TF7lyj3CKxethW7J+
         yTkn7ruXoO4TELMQXWV9qgoXRCA45i6vrOZw6Mx2RYzr6WT44Y8w+eTGjXJmJJ6fyvDT
         /5cCb69Sjr0uVSTxkLVdc38FmW5N8KBEEZk5VL+FK9VTLukhhnT1nIIkh3oyhXh1egLc
         E8nA==
X-Gm-Message-State: APjAAAXScH+NDmwJ68BmM34VUQbOEWqBDubamLHpaH9TQySObSsU0op7
	24tdXVxM/p3n9AZj4Y1SmGRy91L14iGVDWIwiwU=
X-Google-Smtp-Source: APXvYqxi5FSKyF6sYWHE/TKa8JV3wJ+0TbwYIvDv6QSW0rzpI4gFnuCG55xCQPVkFsMBhHnbKsdJUGASYqr2OPG6oCU=
X-Received: by 2002:a02:1981:: with SMTP id b123mr5877390jab.72.1566372452492;
 Wed, 21 Aug 2019 00:27:32 -0700 (PDT)
MIME-Version: 1.0
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190820213905.GB12897@tower.DHCP.thefacebook.com> <CALOAHbBSUPkw-XZBGooGZ9o7HcD5fbavG0bPDFCnYAFqqX8MGA@mail.gmail.com>
 <20190821064452.GV3111@dhcp22.suse.cz>
In-Reply-To: <20190821064452.GV3111@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 21 Aug 2019 15:26:56 +0800
Message-ID: <CALOAHbAt6nm+qSOLGTeo5s5XjQFcasQw9HJfKEEC24xVOoVxwg@mail.gmail.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
To: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 2:44 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Wed 21-08-19 09:00:39, Yafang Shao wrote:
> [...]
> > More possible OOMs is also a strong side effect (and it prevent us
> > from using it).
>
> So why don't you use low limit if the guarantee side of min limit is too
> strong for you?

Well, I don't know what the best-practice of memory.min is.
In our plan, we want to use it to protect the top priority containers
(e.g. set the memory.min same with memory limit), which may latency
sensive. Using memory.min may sometimes decrease the refault.
If we set it too low, it may useless, becasue what memory.min is
protecting is not specified. And if there're some busrt anon memory
allocate in this memcg, the memory.min may can't protect any file
memory.

I appreciate if you could show me some best practice of it.

Thanks
Yafang


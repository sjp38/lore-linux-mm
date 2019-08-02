Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D03B9C0650F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:29:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95E4121726
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:29:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95E4121726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vandrovec.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3755B6B0006; Fri,  2 Aug 2019 19:29:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 326396B0008; Fri,  2 Aug 2019 19:29:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23BCC6B000A; Fri,  2 Aug 2019 19:29:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id B31ED6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 19:29:33 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id c18so16501439lji.19
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 16:29:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=FqoD94WDLyWA8l9zI3MRA8YgAwJDuCPz2geT9v/93AU=;
        b=EDM0W2vuir6HEpzkuYKWded/kSpnqQOoAwH9sMp3YYbzrsSEYAQYhaIRq/Hg0NMRb2
         fpI7wYvgdJxa/tVyhLCzC2oLQV/O9DZZhPt9pZFgkJUnZtTlxhNBfF9DScdUZWMBAprD
         y559nzsU/526+sfEN6kxVSql6JiB05epB64xJh1mJkt25ivX0jOHbiK6QZuIg7smCvqL
         eI/cWVUecV/ibVMP8lo+acrwISyjXATUbcXGzO+RmKMGtzNBEF175v7BndBMS8Vl3Ia2
         bEciNvzjpURA7cdqZpaSp61QZxVWVAuQTsq5R9Fh/1bJWQ22YJ1Pb0fMvEZYANGsVsEW
         /5ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of petrvandrovec@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=petrvandrovec@gmail.com
X-Gm-Message-State: APjAAAXchr1tuTrz8z5UGJkpM++jxg90quF+qNkEHMVxfjp0f+SflZL1
	HCjNGJKXNU62EaNtK+XfIw+57Zdfkc6h2s26vF7KvjGWwE6ntDD++ro8EbOXBeuz9Y2iqqUB45r
	jZyU6NZYPL3z1s6aAXO3tIRuwD/wnlUcDAWliFfRjuNG1JcKRSK7PjYzH8kY2JQo=
X-Received: by 2002:a2e:9117:: with SMTP id m23mr72699166ljg.134.1564788572976;
        Fri, 02 Aug 2019 16:29:32 -0700 (PDT)
X-Received: by 2002:a2e:9117:: with SMTP id m23mr72699149ljg.134.1564788572319;
        Fri, 02 Aug 2019 16:29:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564788572; cv=none;
        d=google.com; s=arc-20160816;
        b=UzxCxxJ98HODim+y66pu2rPNcckSCihoILzaFS+a05qbVqpzTJDCSkfTEvrlmUONxV
         LFVH6hw9OXczQQw7INgIMX8bTcpmH3fstG0SXNg+4lxX5dZaLBlmhrUZsvDA5beWjSU1
         MQU/kw+PscusPKIQ8YTOjc8COye9LdbUC3nOo9kP1RBelgUAS5bEfYwrn/JXKbnNQl3n
         sk/Fo//hiBZ2td+ITUzOFTTfhRHASRKGjY8EpBdlHPaNxtvviB28pv4Aiscn/nIBllIr
         IVXYpONzXb3+/l2tP5XRGiXKYOVvyDgJilWqnnAglzxaoq+904q2ZVhc17e0wkSKm9Rm
         is8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=FqoD94WDLyWA8l9zI3MRA8YgAwJDuCPz2geT9v/93AU=;
        b=bJtDX1VPeTFLbhuqvh4N6zYPHfAtCw6nBgxMyQTBdmz9ECx11gX7Hl+jNzAXd27tB8
         SVdn2sqCEXhmzmlvN0PHia1hfFxtVkALv7vzTaSL99P6rsYFyRMiwrfQkBNmDZ+Kt+Cc
         /QghZs0ZIFfptbXBhAM9JijB63iiXq/cDHsnZ/IlA5vKav6UmqZDRnuigJ+4FvPmRcFp
         rfMSSJ2Pe5PieTChIMR3oUcjXfbbBT+4yRimMnEfPwn0z1AoXeNJvjar/UFo6iO8jRw+
         z4gAvh8Nhzbu3WGQMkhIL+p7YzcMcT7qLeDa78ZkhXJJD3OPDzc4YniY/OR5fI9JAg0G
         cYWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of petrvandrovec@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=petrvandrovec@gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d26sor42026576lji.22.2019.08.02.16.29.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 16:29:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of petrvandrovec@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of petrvandrovec@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=petrvandrovec@gmail.com
X-Google-Smtp-Source: APXvYqxQomGFhJOzhqjL4fHtC06r+EtvDQrM180ePolUOYxy3p36rmppE8ZrP0N69kgRfCGOdkfnpbPRwWIstlW7o8Q=
X-Received: by 2002:a2e:8802:: with SMTP id x2mr52112581ljh.200.1564788571846;
 Fri, 02 Aug 2019 16:29:31 -0700 (PDT)
MIME-Version: 1.0
References: <bug-204407-27@https.bugzilla.kernel.org/> <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
 <20190802203344.GD5597@bombadil.infradead.org> <1564780650.11067.50.camel@lca.pw>
 <20190802225939.GE5597@bombadil.infradead.org>
In-Reply-To: <20190802225939.GE5597@bombadil.infradead.org>
From: Petr Vandrovec <petr@vandrovec.name>
Date: Fri, 2 Aug 2019 16:29:20 -0700
Message-ID: <CA+i2_Dc-VrOUk8EVThwAE5HZ1-zFqONuW8Gojv+16UPsAqoM1Q@mail.gmail.com>
Subject: Re: [Bug 204407] New: Bad page state in process Xorg
To: Matthew Wilcox <willy@infradead.org>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, 
	bugzilla-daemon@bugzilla.kernel.org, 
	Christian Koenig <christian.koenig@amd.com>, Huang Rui <ray.huang@amd.com>, 
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, dri-devel@lists.freedesktop.org, 
	linux-mm@kvack.org
Content-Type: multipart/alternative; boundary="000000000000f93a5c058f2aba0c"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000f93a5c058f2aba0c
Content-Type: text/plain; charset="UTF-8"

On Fri, Aug 2, 2019, 3:59 PM Matthew Wilcox <willy@infradead.org> wrote:

> That doesn't help because we call reset_page_owner() in the free page path.
>
> We could turn on tracing because we call trace_mm_page_free() in this
> path.  That requires the reporter to be able to reproduce the problem,
> and it's not clear to me whether this is a "happened once" or "every
> time I do this, it happens" problem.
>

It happened on 3 of the boots with that kernel.  4th time box either
spontaneously rebooted when X started, or watchdog restarted box shortly
after starting X server.

So I believe I should be able to reproduce it with additional patches or
extra flags enabled.

Petr

>

--000000000000f93a5c058f2aba0c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><div class=3D"gmail_quote"><div dir=3D"ltr" class=3D=
"gmail_attr">On Fri, Aug 2, 2019, 3:59 PM Matthew Wilcox &lt;<a href=3D"mai=
lto:willy@infradead.org">willy@infradead.org</a>&gt; wrote:</div><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex">
That doesn&#39;t help because we call reset_page_owner() in the free page p=
ath.<br>
<br>
We could turn on tracing because we call trace_mm_page_free() in this<br>
path.=C2=A0 That requires the reporter to be able to reproduce the problem,=
<br>
and it&#39;s not clear to me whether this is a &quot;happened once&quot; or=
 &quot;every<br>
time I do this, it happens&quot; problem.<br></blockquote></div></div><div =
dir=3D"auto"><br></div><div dir=3D"auto">It happened on 3 of the boots with=
 that kernel.=C2=A0 4th time box either spontaneously rebooted when X start=
ed, or watchdog restarted box shortly after starting X server.</div><div di=
r=3D"auto"><br></div><div dir=3D"auto">So I believe I should be able to rep=
roduce it with additional patches or extra flags enabled.</div><div dir=3D"=
auto"><br></div><div dir=3D"auto">Petr</div><div dir=3D"auto"><div class=3D=
"gmail_quote"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex"></blockquote></div></div></div=
>

--000000000000f93a5c058f2aba0c--


Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBAC6C0650F
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 01:37:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9539B2084D
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 01:37:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SZiO6DEO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9539B2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 230436B0003; Sun, 11 Aug 2019 21:37:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E1736B0005; Sun, 11 Aug 2019 21:37:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A8B56B0006; Sun, 11 Aug 2019 21:37:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0059.hostedemail.com [216.40.44.59])
	by kanga.kvack.org (Postfix) with ESMTP id DC6106B0003
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 21:37:43 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 86638181AC9B4
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 01:37:43 +0000 (UTC)
X-FDA: 75812064006.29.park03_7d9eb68c5b00b
X-HE-Tag: park03_7d9eb68c5b00b
X-Filterd-Recvd-Size: 4681
Received: from mail-vs1-f65.google.com (mail-vs1-f65.google.com [209.85.217.65])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 01:37:43 +0000 (UTC)
Received: by mail-vs1-f65.google.com with SMTP id c7so1251584vse.11
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 18:37:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2LvnTipJZhZIUoRbWH0WQTQrByqAr4V2iqODb0EELto=;
        b=SZiO6DEOIuyIhDHVG+GnlEin+uNFqKBQipgtk36IXhXF1wSZzH4nnCKhrLWOSlpIRO
         q5pzayzwz5vRvu90mtASG4006WIp47vBQvOex/05Py76sArBAEfJbX+E9g/k7pEJttu7
         NbNu3WpFyjx9+q3+IUMCoU/wL+Qjl4VAcRsj9TSpD1+lghCVx+59zJkpF6mSMskDjRk9
         XOgSue0Fh84YKh7QuLx46d+rHY+y7byVzs5sdi6/Lg5yYhoPRX9p6r2rokgieZslHFvY
         57vbYtPb7tkEuXOS9YcJbostJENVMDO2mt/cBcJuiUuVDanqsAFr8mQ2C4kY2A0NE21x
         6/Fw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=2LvnTipJZhZIUoRbWH0WQTQrByqAr4V2iqODb0EELto=;
        b=s7zMduefV86sKjtSic3YeidKun7K8vq5iQGQ0II/B9w6WcTmLS1iFJzwECi3wdVJs/
         Mhw34xBURyA/xmc2XagZ18teZMMpie7sOv5IYMeaIA9AsmuY+MrTliQNU2aMny373gNt
         hjqGxvY/CkRT3eOGU4xQlVtCCGvAHItfOlpDymweuN5CX4XQ8kQ0fIyhBgfgZtF62Rmc
         zN0tjUCzoLVsrgH4SXzjk00pgXEnCWmTmWXrpnQgwI26S38SB8QuvoLW9NnTywdKzMmz
         yWY7uKJS4USSTxBKQPyJIzGq/vx4G+RansQzH3JetRVVpuNtl7K1J5GQuHbxHbCFt8jm
         1MtQ==
X-Gm-Message-State: APjAAAUcaficFgws2r5LC5yqxFYlf47Zb6ecDsqE6sP7BoFsoUgmcydv
	5tw1O7vctQeIvivgrrR84QciwlGkFMQL1IRKTqqWEw==
X-Google-Smtp-Source: APXvYqyXrQBmouu5GDDT5m91pjiFtd39uZBKfcErjB7T8vaeySN7FBJrwBC4os/PtCmiK1g2TAsdryg5ahnIiPnj/is=
X-Received: by 2002:a67:3251:: with SMTP id y78mr11021809vsy.39.1565573862229;
 Sun, 11 Aug 2019 18:37:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190811184613.20463-1-urezki@gmail.com> <20190811184613.20463-2-urezki@gmail.com>
In-Reply-To: <20190811184613.20463-2-urezki@gmail.com>
From: Michel Lespinasse <walken@google.com>
Date: Sun, 11 Aug 2019 18:37:30 -0700
Message-ID: <CANN689GT3CorHHegQBFR8tiVPqv5XAb2oYLCEbjB=tBhkO2PCw@mail.gmail.com>
Subject: Re: [PATCH 1/2] augmented rbtree: use max3() in the *_compute_max() function
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
	Roman Gushchin <guro@fb.com>, Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@suse.com>, 
	Matthew Wilcox <willy@infradead.org>, 
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 11, 2019 at 11:46 AM Uladzislau Rezki (Sony)
<urezki@gmail.com> wrote:
>
> Recently there was introduced RB_DECLARE_CALLBACKS_MAX template.
> One of the callback, to be more specific *_compute_max(), calculates
> a maximum scalar value of node against its left/right sub-tree.
>
> To simplify the code and improve readability we can switch and
> make use of max3() macro that makes the code more transparent.
>
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>

Thanks. The change is correct but I think I prefer it the "before"
version. My reasons are:

- I don't have a strong style preference either way - it's the same
amount of code either way, admittedly more modular in your proposal,
but also with more indirection (compute_max refers to get_max and
max3). The indirection doesn't hinder readability but IMO it makes it
harder to be confident that the compiler will generate quality code,
compared to the "before" approach which just lays down all the pieces
in a linear way.

- A quick check shows that the proposed change generates larger code
for mm/interval_tree.o:
   2757       0       0    2757     ac5 mm/interval_tree.o
   2533       0       0    2533     9e5 mm/interval_tree.o.orig
  This does not happen for every RB_DECLARE_CALLBACKS_MAX use,
lib/interval_tree.o in particular seems to be fine. But it does go
towards my gut feeling that the change trusts the compiler/optimizer
more than I want to.

- Slight loss of generality. The "before" code only assumes that the
RBAUGMENTED field can be compared using "<" ; the "after" code also
assumes that the minimum value is 0. While this covers the current
uses, I would prefer not to have that limitation.


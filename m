Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91606C3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 22:27:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2728823439
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 22:27:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ucr.edu header.i=@ucr.edu header.b="KHd6MyKW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2728823439
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ucr.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CAFD6B0006; Fri, 30 Aug 2019 18:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87B626B0008; Fri, 30 Aug 2019 18:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 743366B000A; Fri, 30 Aug 2019 18:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5013A6B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 18:27:25 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E5245181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 22:27:24 +0000 (UTC)
X-FDA: 75880531608.24.sock44_6553fd387f17
X-HE-Tag: sock44_6553fd387f17
X-Filterd-Recvd-Size: 6661
Received: from mx1.ucr.edu (mx1.ucr.edu [138.23.248.2])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 22:27:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=ucr.edu; i=@ucr.edu; q=dns/txt; s=selector3;
  t=1567204111; x=1598740111;
  h=mime-version:references:in-reply-to:from:date:message-id:
   subject:to:cc;
  bh=+AxKleiBOotn72mRXxY/KudOmnLMJMiIcrvaqwrtHdw=;
  b=KHd6MyKW4QFeaEmXvzxfAc8Gy0NW7V37yy45qTrUV4mEV2kQKR683Vd2
   g/tWWexat/KswjN2mzQuTMgaa+7pbM86Vfto1ebRp7LyLCv7SDgM7x2uJ
   MM1oHHEFxr4ooonsJNfX/PgPhSExOyhYtq0sMS6qaj7TYl4+AS+YuHb9t
   cL7yN87yHP2WapzOfGD+YZvKOIPMHuFi7NPkZmCklZnLvDPvPnvzyuk7W
   6ziFUBNINZH9Ut14sJL2YmVEHnl2/PbSaW4axiNEQJ1iz1w4+DPlPNywn
   XFGaWTxE0ER3oXp9R1CnKYNYli0u6GTotQ1TqvZ9CKc+RF0ohX26r9eeb
   A==;
IronPort-SDR: CQYI4lsAehPYwWqaKTNoeUP48CB/7R7awjPaOGiwLfa8lA2MfG0kZz3cX0yqddX95xdG4xknBN
 R1QqgDmItKWD9m4yPbdvfON9yS0FOBSIYbEslDJxL/FuiFKXz/5woRaoGBR/rTOl9BOd6wYoAA
 +q35MLW5rMgw1577S0h6BwhlIM/0sSQ0p7TCP+oEQKzCLS4suUbzyAnYrtaBT5LxyWbgH6FVBq
 3HqpiEuHMm/lO6QLzCm7IgG6TcaOuVJeGbqxe8Kr53Gh1EfaQiMusAsY653no3uIg5+UeAHN94
 T+M=
IronPort-PHdr: =?us-ascii?q?9a23=3AE0nuMhHdorZa+70Fh3ZM4Z1GYnF86YWxBRYc79?=
 =?us-ascii?q?8ds5kLTJ78ocywAkXT6L1XgUPTWs2DsrQY0rCQ6v69EjRRqb+681k6OKRWUB?=
 =?us-ascii?q?EEjchE1ycBO+WiTXPBEfjxciYhF95DXlI2t1uyMExSBdqsLwaK+i764jEdAA?=
 =?us-ascii?q?jwOhRoLerpBIHSk9631+ev8JHPfglEnjWwba5sIBmssAnct8kbjYR+Jqs11x?=
 =?us-ascii?q?DEvmZGd+NKyG1yOFmdhQz85sC+/J5i9yRfpfcs/NNeXKv5Yqo1U6VWACwpPG?=
 =?us-ascii?q?4p6sLrswLDTRaU6XsHTmoWiBtIDBPb4xz8Q5z8rzH1tut52CmdIM32UbU5Ui?=
 =?us-ascii?q?ms4qt3VBPljjoMOiUn+2/LlMN/kKNboAqgpxNhxY7UfJqVP+d6cq/EYN8WWX?=
 =?us-ascii?q?ZNUsNXWidcAI2zcpEPAvIOMuZWrYbzp1UAoxijCweyGOzi0SNIimPs0KEmz+?=
 =?us-ascii?q?gtDQPL0Qo9FNwOqnTUq9D1Ob8QXuC0zajIzSjDb/RL0jj+6IjHaBEhquyLUL?=
 =?us-ascii?q?NwcMvRyVMgFwLZglmMp4HoJC6V2fgXs2SB8eVvSP+vhnchpgpsoTav3t8hhp?=
 =?us-ascii?q?fVio8R0FzJ9iV0zJwrKdGkS0N3e8OoHZ9TuiycKoB4WNktQ3tytyY/0rAGvJ?=
 =?us-ascii?q?m7czUUx5k/3B7fbuCHc5CP4hL+SOadOTd4i2xheLK4nxuy9FKvyuz4VsWt1F?=
 =?us-ascii?q?ZKrDdJnsDCtnwQ0xHe6dKLSvR6/kem1jaP0x7c5vtYLkAzkKrXM58hwrgumZ?=
 =?us-ascii?q?oPqUnPADP6lUHsgKKVdkgo4Pak5/jkb7n8u5ORM4x5hhn7Mqs0m8y/Beo4Mh?=
 =?us-ascii?q?IJX2ie4em91Lzi/U3jT7VLkvE6jqfUvYvHJcsHvK61GRFa3Zs+6xqnFTepzM?=
 =?us-ascii?q?wYnWUbLFJCYB+Hi4npO1fTIPH3FPu/hlGsnSxox/DYJLLuHpbNImLEkLf7cr?=
 =?us-ascii?q?Yuo3JbnS8yxtBW49p0DboCJ7qnX0/2v9/fJhw0KQq5x6DgEtorha0EXmfaM6?=
 =?us-ascii?q?6LML7V+W2I7+Nnd/ieZIYU4G6mA+Uu/bjjgWJvygxVRrWgwZZCMCPwJf9hOU?=
 =?us-ascii?q?jMJCO02to=3D?=
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: =?us-ascii?q?A2GJAACqgmddgMbQVdFlHgEGBwaBVgY?=
 =?us-ascii?q?LAYQJKoQhjwiBbQUdk3SHHwEIAQEBDi8BAYQ/AoJZIzcGDgIDCAEBBQEBAQE?=
 =?us-ascii?q?BBgQBAQIQAQEJDQkIJ4VDgjopAYJoAQEBAxIRBFIQCwsDCgICJgICIhIBBQE?=
 =?us-ascii?q?cBhMIGoULnTyBAzyLJH8ziGkBCAyBSRJ6KIt3gheBEYMSPodPglgEgS4BAQG?=
 =?us-ascii?q?UTpYFAQYCAYIMFIwoiCkbmF0tphAPIYFFgXszGiV/BmeBToJOFxWOLSIwj10?=
 =?us-ascii?q?BAQ?=
X-IPAS-Result: =?us-ascii?q?A2GJAACqgmddgMbQVdFlHgEGBwaBVgYLAYQJKoQhjwiBb?=
 =?us-ascii?q?QUdk3SHHwEIAQEBDi8BAYQ/AoJZIzcGDgIDCAEBBQEBAQEBBgQBAQIQAQEJD?=
 =?us-ascii?q?QkIJ4VDgjopAYJoAQEBAxIRBFIQCwsDCgICJgICIhIBBQEcBhMIGoULnTyBA?=
 =?us-ascii?q?zyLJH8ziGkBCAyBSRJ6KIt3gheBEYMSPodPglgEgS4BAQGUTpYFAQYCAYIMF?=
 =?us-ascii?q?IwoiCkbmF0tphAPIYFFgXszGiV/BmeBToJOFxWOLSIwj10BAQ?=
X-IronPort-AV: E=Sophos;i="5.64,443,1559545200"; 
   d="scan'208";a="5118045"
Received: from mail-lj1-f198.google.com ([209.85.208.198])
  by smtp1.ucr.edu with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 30 Aug 2019 15:28:29 -0700
Received: by mail-lj1-f198.google.com with SMTP id y25so1010873lji.21
        for <linux-mm@kvack.org>; Fri, 30 Aug 2019 15:27:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=zLm09boqVLNebbJn0KRM9g9k9tAtM8q9U95oJU1h0L0=;
        b=nVbHfO/IM+K7otGk3ziEKTWlTsAlVAQTUAbYppikjkPrnhoFGaim5NHPaOGHXrCEGq
         2ijruE98Ue+0U3q2xaUEDTlyo6dXqKibcFf8xYGni1fe9tZUjIO+SQLNNraZmYASF9BJ
         Og0Vx6srIYVpOnzPDj01Y84u5I8CUyGpWCjq/zWoR1ftjCiMC475CUyhsQZhgAcHxKh0
         od9NoyHUYsOz9FjZml46krWUePDsVebbx/G6K9GKckf5TCN3p+DYUb1fuz3w+e7fiF6D
         kJEGYEskhHpidzCkmK8HGF3oTq2WS1PeBwSNMZPydNTFztjb0YUHaFX5ZhZe4hpihMx/
         8Vcg==
X-Gm-Message-State: APjAAAXsZl9s06c9htR8/SvkJpBsryTMjcoJNerEJoah1b8yqLBEQNuQ
	Ykzb3fQ0TAVUkV8h56pbXFuNfw1odXnWkzwCFkqLvUGCb1VZaOe7hwi8Kqm/1Se9yNnySGRxYUW
	IaEpBd+96xPvCWsoCY1O4NGz7NO3e
X-Received: by 2002:a19:2d19:: with SMTP id k25mr11524774lfj.76.1567204039644;
        Fri, 30 Aug 2019 15:27:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNwVPvOdN/tveaY5mDrcDGRnQDZr8owb4Bj/v//Ng1I8rWXAU6aT8pAFp3c8BU1Pct5O5eSmP/cI28qOpREA4=
X-Received: by 2002:a19:2d19:: with SMTP id k25mr11524763lfj.76.1567204039450;
 Fri, 30 Aug 2019 15:27:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190822062210.18649-1-yzhai003@ucr.edu> <20190822070550.GA12785@dhcp22.suse.cz>
 <CABvMjLRCt4gC3GKzBehGppxfyMOb6OGQwW-6Yu_+MbMp5tN3tg@mail.gmail.com> <20190822201200.GP12785@dhcp22.suse.cz>
In-Reply-To: <20190822201200.GP12785@dhcp22.suse.cz>
From: Yizhuo Zhai <yzhai003@ucr.edu>
Date: Fri, 30 Aug 2019 15:27:50 -0700
Message-ID: <CABvMjLRFm5ghgXJYuuNOOSzg01EgE1MazAY7c6HXZaa6wogF8g@mail.gmail.com>
Subject: Re: [PATCH] mm/memcg: return value of the function
 mem_cgroup_from_css() is not checked
To: Michal Hocko <mhocko@kernel.org>
Cc: Chengyu Song <csong@cs.ucr.edu>, Zhiyun Qian <zhiyunq@cs.ucr.edu>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000032, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Our tool did not trace back the whole path, so, now we could say it
might happen.

On Thu, Aug 22, 2019 at 1:12 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 22-08-19 13:07:17, Yizhuo Zhai wrote:
> > This will happen if variable "wb->memcg_css" is NULL. This case is reported
> > by our analysis tool.
>
> Does your tool report the particular call path and conditions when that
> happen? Or is it just a "it mignt happen" kinda thing?
>
> > Since the function mem_cgroup_wb_domain() is visible to the global, we
> > cannot control caller's behavior.
>
> I am sorry but I do not understand what is this supposed to mean.
> --
> Michal Hocko
> SUSE Labs



-- 
Kind Regards,

Yizhuo Zhai

Computer Science, Graduate Student
University of California, Riverside


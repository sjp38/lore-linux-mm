Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62221C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 23:08:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E895D2148D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 23:08:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E895D2148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49D738E000A; Fri,  1 Feb 2019 18:08:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4499A8E0001; Fri,  1 Feb 2019 18:08:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C5688E000A; Fri,  1 Feb 2019 18:08:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 000C48E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 18:08:08 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w28so8857856qkj.22
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 15:08:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=ecYcp0LTAxkc88dbkPqudvlPci149KIqQNe1W7Ra8JQ=;
        b=H6kMcPHzWuqQhf0cxun7/KUAJ6g5fx+n/mQ9q9mIOEQkZZRrmXZF/pspJ33bFdFfh4
         ShXmANYi8faaeExF+CmvYp4QiJZtNgexs4IJx5PdTICcJAQWG6DcqYPK8/Z+r+XI2vQU
         T4umSjtggGfat/W2QL5tiZB47txvSBk7qJwZrr+OCFCHlzT/pudSgE32kBvXRMnBGK1v
         +Gylr9XE3IhcSXbh0b9P15G1yjWh4Hy5Xprx33edMN+B1KuTaKkMMA6Jmo4CLNowSjOe
         dz2MxYegOZEIcrgME865pTgbyJIaBWTROnCs0yfEmuDB+3Ja2/xleyL9UcimEGYn3Ig1
         KWkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZ34Vs54kQUvpKAiERirb/rAVINIeF8KEXKWN5PdH2CB0IecSaa
	5DjJx0VBwyvGrvgb3STfcPZq/JC+wMvCDO1IvnaroyTnkiLPb//pqVhz9I4crjwO83TB116B+EU
	NKJfPE3v+yF8OgmlHJJshODljmpmiUAWJ/3qMkoeZEb7/wo+GuQvnXXgyGXxoSgi/JA==
X-Received: by 2002:aed:2283:: with SMTP id p3mr407404qtc.58.1549062488694;
        Fri, 01 Feb 2019 15:08:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbmERsxDrk4PGHyJu5StFpvuDp/z/8/ibVSVp1mb7gAx35PMWv7GzrLcTyrXbgfyZYRFsF1
X-Received: by 2002:aed:2283:: with SMTP id p3mr407378qtc.58.1549062487958;
        Fri, 01 Feb 2019 15:08:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549062487; cv=none;
        d=google.com; s=arc-20160816;
        b=bP+2vxJRlNu5g3ryJc3axHSQv2hjcMswpNKPePiQdopggyyBRI3qM4BDhoZbEVKe4G
         7Y/+kJw0UajvaZiTBcw3YAeO7KXtfp9lkjKTmcBmZU01oFbK677NNokKxydUawEnvReX
         ufFGgLQ1si0O0cD4oZK8bBUyAGSJz3KDn3XvorNwDxZTVtyrqQ83EMTDgnZifMSL64IJ
         MN5SquZ1vkreGqNfkmxf7RuIcBQIch5xffHJyKejO9jRTLdOuOOGmfXbRQ1IlMyJzzpJ
         NH99Xn2QiiYczC3Y9D92O8sUFaDXLx8GLS9qsIE3is9qtt2vZXmkhzkqV69onQy6zfjv
         Y7Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=ecYcp0LTAxkc88dbkPqudvlPci149KIqQNe1W7Ra8JQ=;
        b=CaGo5/kj4WUj5EOjqioqeKxND+tIfkDCdVVm149bAv/0Ya6cYu4dGTRmXReGiLsWD8
         5Oir2veD3liuU8AMhppvGSrktH9tO3wb80xV4hc39is9fugz530YR77G98g+9KWrnKuj
         t+tYmG2SMkrs76gGAsQZgaSDysVOOC+PZMzLorZrNBx/9ErJq91C2dbf5jGhywL80b5P
         uXnQDmx/d2EbzhTs02Ig2wTciCsGhl/P+pAWzS8j9xC/tDzJDmgujD+wCSCYAMTDan0T
         fTw7uJRjgGHdrKP4SaNxFkpMRKSjksit9hyOXstYSu3szZOfiINanfExOT1ojJ4LQ5O9
         acOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l45si263303qtc.21.2019.02.01.15.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 15:08:07 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 08D261E339;
	Fri,  1 Feb 2019 23:08:07 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DF190100190B;
	Fri,  1 Feb 2019 23:08:06 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id AB1891809546;
	Fri,  1 Feb 2019 23:08:06 +0000 (UTC)
Date: Fri, 1 Feb 2019 18:08:06 -0500 (EST)
From: Jerome Glisse <jglisse@redhat.com>
To: Balbir Singh <bsingharora@gmail.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Message-ID: <626576501.100359304.1549062486006.JavaMail.zimbra@redhat.com>
In-Reply-To: <20190201224809.GK26056@350D>
References: <201902020011.aV3IBiMH%fengguang.wu@intel.com> <20190201224809.GK26056@350D>
Subject: Re: [linux-next:master 5141/5361] include/linux/hmm.h:102:22:
 error: field 'mmu_notifier' has incomplete type
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [10.10.122.133, 10.4.195.14]
Thread-Topic: include/linux/hmm.h:102:22: error: field 'mmu_notifier' has incomplete type
Thread-Index: 7epFgXjUxfGKq//wU3Nzse+L2e/e2Q==
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Fri, 01 Feb 2019 23:08:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> On Sat, Feb 02, 2019 at 12:14:13AM +0800, kbuild test robot wrote:
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next=
.git
> > master
> > head:   9fe36dd579c794ae5f1c236293c55fb6847e9654
> > commit: a3402cb621c1b3908600d3f364e991a6c5a8c06e [5141/5361] mm/hmm:
> > improve driver API to work and wait over a range
> > config: x86_64-randconfig-b0-02012138 (attached as .config)
> > compiler: gcc-8 (Debian 8.2.0-14) 8.2.0
> > reproduce:
> >         git checkout a3402cb621c1b3908600d3f364e991a6c5a8c06e
> >         # save the attached .config to linux build tree
> >         make ARCH=3Dx86_64
> >=20
> > All errors (new ones prefixed by >>):
> >=20
> >    In file included from kernel/memremap.c:14:
> > >> include/linux/hmm.h:102:22: error: field 'mmu_notifier' has incomple=
te
> > >> type
> >      struct mmu_notifier mmu_notifier;
> >                          ^~~~~~~~~~~~
> >=20
> > vim +/mmu_notifier +102 include/linux/hmm.h
> >=20
> >     81
> >     82
> >     83=09/*
> >     84=09 * struct hmm - HMM per mm struct
> >     85=09 *
> >     86=09 * @mm: mm struct this HMM struct is bound to
> >     87=09 * @lock: lock protecting ranges list
> >     88=09 * @ranges: list of range being snapshotted
> >     89=09 * @mirrors: list of mirrors for this mm
> >     90=09 * @mmu_notifier: mmu notifier to track updates to CPU page ta=
ble
> >     91=09 * @mirrors_sem: read/write semaphore protecting the mirrors l=
ist
> >     92=09 * @wq: wait queue for user waiting on a range invalidation
> >     93=09 * @notifiers: count of active mmu notifiers
> >     94=09 * @dead: is the mm dead ?
> >     95=09 */
> >     96=09struct hmm {
> >     97=09=09struct mm_struct=09*mm;
> >     98=09=09struct kref=09=09kref;
> >     99=09=09struct mutex=09=09lock;
> >    100=09=09struct list_head=09ranges;
> >    101=09=09struct list_head=09mirrors;
> >  > 102=09=09struct mmu_notifier=09mmu_notifier;
>=20
> Only HMM_MIRROR depends on MMU_NOTIFIER, but mmu_notifier in
> the hmm struct is not conditionally dependent HMM_MIRROR.
> The shared config has HMM_MIRROR disabled
>=20
> Balbir
>=20
>=20

I am bad with kconfig simplest fix from my pov is adding
select MMU_NOTIFIER to HMM config as anyway anything that
will have HMM will need notifier.

config HMM
  bool
+ select MMU_NOTIFIER
  select MIGRATE_VMA_HELPER


Cheers,
J=C3=A9r=C3=B4me


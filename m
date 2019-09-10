Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CF98C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 12:56:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B22DC20863
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 12:56:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b3q/Lpqg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B22DC20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FF916B0003; Tue, 10 Sep 2019 08:56:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 089686B0006; Tue, 10 Sep 2019 08:56:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB92C6B0007; Tue, 10 Sep 2019 08:56:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0096.hostedemail.com [216.40.44.96])
	by kanga.kvack.org (Postfix) with ESMTP id C54216B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:56:42 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6255D181AC9C4
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:56:42 +0000 (UTC)
X-FDA: 75919010244.03.rock27_1d6519158722e
X-HE-Tag: rock27_1d6519158722e
X-Filterd-Recvd-Size: 4120
Received: from mail-lj1-f195.google.com (mail-lj1-f195.google.com [209.85.208.195])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:56:41 +0000 (UTC)
Received: by mail-lj1-f195.google.com with SMTP id q64so5770508ljb.12
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:56:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ThZUjst48nBsQQrwmyp4kkeqgEJqPKlkWHGIw30bhN4=;
        b=b3q/Lpqg9Sp34lOtUgzjULZ9aV3rmUKNkbT0CrVcbQzJ9ET1bQxl9z9U9BxJs7qMny
         n94QaUzz81Lo0A4ZGMfzKns8Agjx4Bf2PoMlceqJGMeNwuOD6bdZLREa7H/LenwpuCo+
         Y+oIzhIA9H8HYwHjTTtV9f4IG3o5KfXSnGFFr7IkSzv9m2X9+F5+M82mQ5Go8kzhU+tg
         qekG0xSEC51m0qJTX5VfXsIxSYWuJojb6yItYiPBCiqbui+363+EO94btvTPeNABHwV3
         CZ2ul6a0X5Gv20H/I114/+V5GgEUBeNlseTDrMc2me8SZZpFZtQZwa83USnlRJ0cxUw/
         /Abg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ThZUjst48nBsQQrwmyp4kkeqgEJqPKlkWHGIw30bhN4=;
        b=Hz9akaCV2JhV6StoHIOC97dntFRO5ZuWuOa5Hu9JXD4cy2V+k/owe27f7rBACYtD42
         +kIJsYX27eT5c2F7BVdmmmw0Iq80UI+0NaKDHngEfMxzVwFzcGxfkh0F9E1YMVT3Y2mc
         Y53F6Ywacv8FM1r/mnj90PKZz4UBXaA7QFPJIcPxErmTHhb+DzY1paROUcUro0u/LvkH
         wuwvX4JqYnqHbWnwoOWjne9cmprGnG3+YAESMF3kEKvYQe2h2sIXdv1/BJk2EV2cn3G5
         OzDMjC7+GnGlPmDLit/ZBW0dJrKpM7J0RavFFh48iNGoedV6x0Lv8N760Rcllv/bAT/k
         vRXA==
X-Gm-Message-State: APjAAAVn85FqlHUh5CQ1B5V9nyZcJL0H+PBRjzBpl3/G7gspSIOmOUNo
	K0C+ytNfDeqOuRfyhfiWcbxvlMjaohAsveWEvqo=
X-Google-Smtp-Source: APXvYqxq4KmKDj3pDHYdpmtLYyyUHmVZr8CQS2gK4J2CDzE4ivbWi++aFawMEADWVn/+QqgnnwuW1PQNzQrcK1Tku6s=
X-Received: by 2002:a2e:83d6:: with SMTP id s22mr19759114ljh.104.1568120200429;
 Tue, 10 Sep 2019 05:56:40 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1567889743.git.jrdr.linux@gmail.com> <20190909154253.q55olcm4cqwh7izd@box>
In-Reply-To: <20190909154253.q55olcm4cqwh7izd@box>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 10 Sep 2019 18:26:28 +0530
Message-ID: <CAFqt6zZNHGdgaiiRvz-1AFe5g1652oyZpNQidK1V0B6weQHz0w@mail.gmail.com>
Subject: Re: [PATCH 0/3] Remove __online_page_set_limits()
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, 
	sashal@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	Juergen Gross <jgross@suse.com>, sstabellini@kernel.org, 
	Andrew Morton <akpm@linux-foundation.org>, david@redhat.com, osalvador@suse.com, 
	Michal Hocko <mhocko@suse.com>, pasha.tatashin@soleen.com, 
	Dan Williams <dan.j.williams@intel.com>, richard.weiyang@gmail.com, Qian Cai <cai@lca.pw>, 
	linux-hyperv@vger.kernel.org, xen-devel@lists.xenproject.org, 
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 9, 2019 at 9:12 PM Kirill A. Shutemov <kirill@shutemov.name> wrote:
>
> On Sun, Sep 08, 2019 at 03:17:01AM +0530, Souptick Joarder wrote:
> > __online_page_set_limits() is a dummy function and an extra call
> > to this can be avoided.
> >
> > As both of the callers are now removed, __online_page_set_limits()
> > can be removed permanently.
> >
> > Souptick Joarder (3):
> >   hv_ballon: Avoid calling dummy function __online_page_set_limits()
> >   xen/ballon: Avoid calling dummy function __online_page_set_limits()
> >   mm/memory_hotplug.c: Remove __online_page_set_limits()
> >
> >  drivers/hv/hv_balloon.c        | 1 -
> >  drivers/xen/balloon.c          | 1 -
> >  include/linux/memory_hotplug.h | 1 -
> >  mm/memory_hotplug.c            | 5 -----
> >  4 files changed, 8 deletions(-)
>
> Do we really need 3 separate patches to remove 8 lines of code?

I prefer to split into series of 3 which looks more clean. But I am ok
with other option.
Would you like to merge into single one ?


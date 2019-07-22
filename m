Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E58A0C76191
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 01:37:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8310520659
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 01:37:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cPo2tFvm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8310520659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF2D16B0003; Sun, 21 Jul 2019 21:37:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7DC76B0006; Sun, 21 Jul 2019 21:37:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6A818E0001; Sun, 21 Jul 2019 21:37:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id B09E46B0003
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 21:37:49 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id s145so17344161vke.18
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 18:37:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/YkkaXfp503K6bLavwX+qLvL6w0rpc7OLS8RSOtuP+M=;
        b=FMj2YwE4sdCt0KFgUzLB+4Gq67di40l3fsnTVJBJn8FqgcfnlGm8umb+xGmRwg7TBw
         693Em+U48BVTSB2D3RBm9PAKLMipvN94NyLtsPYrmfV3Wm1DV++EhXYk4ZO/T3JCiy4l
         sAjWdpc39VRjeOIfanc/zFSRfK5lLIWR+D8N79lANZpCy7+SgpOHqigqAuCRTZiVLuy9
         rs1SifcyoSofRbo62zt8omamRnXz5As/qfCtZHwjxVG7otB/luyZtGHtjEDFUm7Mjl5C
         wcWTqOV1/uAEBZLjYnjYQs1RAc+t7idiaIyI2keNPdW+6n0Hk4hGCjyEMkNYQXDeegp4
         YDyg==
X-Gm-Message-State: APjAAAW1KSkOyFCTgtqzBOp8S4EOYcal13jOtDzIPh76Xcw4wyJ++I8P
	drTYeaZ+v7jQQv6n5B4zCXYF7HGHyo1q4Q/R+sDd74nj7HAjb3Vxew62xt+2vFehaJCf5kRS9Tu
	b1pnNX7oswz94Q8rVOq3P7K85hDUKJ3KU/J5JCb/T7/a1740DEaxEk8G6olELzFXk7g==
X-Received: by 2002:a67:2ec8:: with SMTP id u191mr42655262vsu.39.1563759469385;
        Sun, 21 Jul 2019 18:37:49 -0700 (PDT)
X-Received: by 2002:a67:2ec8:: with SMTP id u191mr42655237vsu.39.1563759468636;
        Sun, 21 Jul 2019 18:37:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563759468; cv=none;
        d=google.com; s=arc-20160816;
        b=oGTQFmWfcQCh4vHRXc0CP5wJkIcKUxTmUhV2pu6U8l10Evqv2U7YKRucIZKlp4ozw7
         qKtI/H7ULGlVW4rX6D5OJ5kSnRepHrOtWTF2JbNOTe8Ftq+4S3FLHHHB/Ik7vi5vhYic
         qs1CiggNZzLx1WgaP+xnduJlvoGtI8Uv4zXUB/qvwVpo/aPvS3A67RWju8YXarYMpRiR
         kicCg28c0H+2YBF+zpej7/6c8F3Qw1JzyIGFBIEB/1BsTyBoVCKi56DIQ2nuFbqL2n9X
         TsRvp61A6Otjl/99ClxV5sDoaeTQgO1ZLKa7NNFpjZH4n/MaOPFrIBUjIV+mxMTtKqyb
         Xfpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/YkkaXfp503K6bLavwX+qLvL6w0rpc7OLS8RSOtuP+M=;
        b=CMuFbg3AUwa7IonNfdu/ERSwUFo50u5hCmSMQ9gjXbhpjPZalQryc/Jaue+bDi2YAz
         39QUAS0l5g8MDvfsXDuAjXb1SqKAtP6iftMbac6x9FvgN+iIzQ0qK+w67hn/ZKSgCIRy
         FcoLKKTZJmIGAfJUeG6ODrCOWIXQ3yxlLQnrKsSIfslOy0bHvruKgo8NMqgKcMfr7IlG
         HBQhVnJKKVnfmSEdEmTcjcl1ijFsSt47cvFKBmSVOYql6kuFjx2sTXdSC8YrYE91QnX4
         e49L3GQs9PREZ5Z7zQpdrKODsg/ECqCw0dAcqITvgfaoNkqM9vPAY6AjxOc4IeEKKssZ
         1/aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cPo2tFvm;
       spf=pass (google.com: domain of huang.ying.caritas@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huang.ying.caritas@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f93sor18699720uaf.74.2019.07.21.18.37.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 18:37:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of huang.ying.caritas@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cPo2tFvm;
       spf=pass (google.com: domain of huang.ying.caritas@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huang.ying.caritas@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/YkkaXfp503K6bLavwX+qLvL6w0rpc7OLS8RSOtuP+M=;
        b=cPo2tFvmLuL6fLvqjzIrpG5LQd6ZWvV9aljHPmVYV9oIi91hq7SbO+hBg0Ef1tnZv/
         y8Kpw/wqFcD4YVj4iq6eINMCPzxoCoeL556+nFs/cIezGZvZ26tghKRDHxKgo2v3m1P6
         a3xfjEZCDBscay3d0wlHtY7gFCrahakcsuViTLI4gk2ISuSIXrCpN/fstZxpNPyaKp8p
         HwfNUYROO68VNeFQ6QD8mC0YCspXYUWalaES/UqK7EPG5+Z8uh2drVV287yRExzoBTzG
         X7GeixClBJda7OLDJWQQCK6lN3ZwIHtmTkBmnb8GWsbxRDOHRrKqV8FWLZQmEBR4pXmO
         Ox5g==
X-Google-Smtp-Source: APXvYqxLgColy907bv+RwBJRyVN1Bx58/q3rCSAwiU5gvj3bLTrGLzMLnM+/DiRXaLqljPpql6cWCfolPagxy7+VP3s=
X-Received: by 2002:ab0:70b1:: with SMTP id q17mr15913997ual.100.1563759468363;
 Sun, 21 Jul 2019 18:37:48 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
In-Reply-To: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Mon, 22 Jul 2019 09:37:37 +0800
Message-ID: <CAC=cRTMz5S636Wfqdn3UGbzwzJ+v_M46_juSfoouRLS1H62orQ@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Huang Ying <ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Mikhail,

On Wed, May 29, 2019 at 12:05 PM Mikhail Gavrilov
<mikhail.v.gavrilov@gmail.com> wrote:
>
> Hi folks.
> I am observed kernel panic after update to git tag 5.2-rc2.
> This crash happens at memory pressing when swap being used.
>
> Unfortunately in journalctl saved only this:
>
> May 29 08:02:02 localhost.localdomain kernel: page:ffffe90958230000
> refcount:1 mapcount:1 mapping:ffff8f3ffeb36949 index:0x625002ab2
> May 29 08:02:02 localhost.localdomain kernel: anon
> May 29 08:02:02 localhost.localdomain kernel: flags:
> 0x17fffe00080034(uptodate|lru|active|swapbacked)
> May 29 08:02:02 localhost.localdomain kernel: raw: 0017fffe00080034
> ffffe90944640888 ffffe90956e208c8 ffff8f3ffeb36949
> May 29 08:02:02 localhost.localdomain kernel: raw: 0000000625002ab2
> 0000000000000000 0000000100000000 ffff8f41aeeff000
> May 29 08:02:02 localhost.localdomain kernel: page dumped because:
> VM_BUG_ON_PAGE(entry != page)
> May 29 08:02:02 localhost.localdomain kernel: page->mem_cgroup:ffff8f41aeeff000
> May 29 08:02:02 localhost.localdomain kernel: ------------[ cut here
> ]------------
> May 29 08:02:02 localhost.localdomain kernel: kernel BUG at mm/swap_state.c:170!

I am trying to reproduce this bug.  Can you give me some information
about your test case?

Best Regards,
Huang, Ying


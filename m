Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64582C46470
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 19:28:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D0BE240FA
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 19:28:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VqlMVnHD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D0BE240FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCF406B026B; Wed, 29 May 2019 15:28:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7F4A6B026D; Wed, 29 May 2019 15:28:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A46DF6B026E; Wed, 29 May 2019 15:28:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 860C36B026B
	for <linux-mm@kvack.org>; Wed, 29 May 2019 15:28:18 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id m1so2708889iop.1
        for <linux-mm@kvack.org>; Wed, 29 May 2019 12:28:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OIRn9ZjK+7v7i28Ava6tGeb+unXhaKu47hvyl94CDxo=;
        b=LwX1d1adbO3Bm+I6ux413zOsqWHu/gKDzzA8iMr2wOukrdi4sZTzfr+e+3bU5eR7Wm
         W17pfC5SHTs3NtufQPasVeRK43G8ODHXkYE1pQg/HVqLT9s1ubtwCUjOrjrBcu3wZGDY
         KteIlaYO73Tzg8+v3oHoYrUH1120y7620p2V4PRmNfZLk3xnR0j7v7Sg1caji0J5SEBU
         VQNdPPwI39bn2TnsIYz1jpsQ1leH1MsJPwdG/VL0QkyZmAze9mld/H8WpKZvhe3suXNM
         yzKc24FjLPBexMhXewWv/f05uBKKj6L+oNdWLYebfH2w6p+8lqIOREs55jB98rgXSvzU
         Hnpg==
X-Gm-Message-State: APjAAAUb35o+oIoWPhr6NJxJghA/txMumvnyKnLw7pb+sbypnt2Zhc2z
	nx0rc6juplMKRexhMcY33m/qu3UEMQpmcttXsCv89zNlbHYXfsiMpywQAYm9Y4ajglg92Pp1PCc
	v/jkfUcU9b48C9dzLDkOt/9qtTO7iaSXU2WdO4pV/IHfu+YpRqeJAixMj4esLcXFi3Q==
X-Received: by 2002:a6b:6a14:: with SMTP id x20mr8358397iog.269.1559158098230;
        Wed, 29 May 2019 12:28:18 -0700 (PDT)
X-Received: by 2002:a6b:6a14:: with SMTP id x20mr8358366iog.269.1559158097339;
        Wed, 29 May 2019 12:28:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559158097; cv=none;
        d=google.com; s=arc-20160816;
        b=axTrooTN6lKfTotGxhYbuFMSnf5NE8G5PkXwpsAZBpdmiuru12/wLKgiQTU/cpySTy
         2FyWRck66cWyjHd03g+HU8tB2OnDKw1EcDV+gfV1iDmXxq3zG/nBh89tGkXACNnJIYgb
         Bl2fKeSLpzO578Cprcc2wnpqJDwjj+HeBHPyn1680shO+MT/nlTzkD/mYArJSV+kmmMH
         bIMOgE3pXuXQjm2Plad1XJ4PNTBJ0g6ixj2Tg2LpQNUJB89hLg//Rla6mlnQkI4vEEi1
         +WgNu22dTyBkkYAx2HeDt43DPLydQTULtb3qAWm1u4MC2StotSI/wUIPH2nDP27AofVi
         yT+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OIRn9ZjK+7v7i28Ava6tGeb+unXhaKu47hvyl94CDxo=;
        b=KAmIuTi2J7DpgxKPVzhKqpyaqPNciTBcLJNuhRSVERZCfBkYz0R0YCjHJu6oNTJPwg
         wQlJN4ulNTmRVi4EoaoD5gI7fcWb7b+7gI7vs05sclbIRBJKUDkWWhdG5SyE/ZGQ0R+K
         TskEHn/GY3drnE0kcV7z8MjEQrjnnnbGfSHiDzR8SVxaBhGbbSo1K/Jf+PZyGjLB+vcN
         z2c/ZMBoXPvmFiqUJ5FKW8jlu83sfwVrX953ne4PBjOwdR9tKo0oVuOL5fLy0RpFsBwz
         VQDK7BslT4Nj87Ez/Bv/4wAgorqkU1i44dnhp3LkixCLuAJXO/DlhP4yY97r6eg40Bh5
         bfCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VqlMVnHD;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y72sor669420ity.29.2019.05.29.12.28.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 12:28:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VqlMVnHD;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OIRn9ZjK+7v7i28Ava6tGeb+unXhaKu47hvyl94CDxo=;
        b=VqlMVnHDOdOImD0u30QwK/qjrrBVbzTwgs6NDmePKwOeoQW8b6YlNua2HHrWg82oLv
         EK1df5i7oh79IkdtRnJlfcdi1q4n3gyDhwt7k0n8xOoBG1lp7e8XW2G3Rne/deI9SahX
         vWlrrc3hgUzr84RGDNU0BXn4r31xgGud131DrhkqpDwyPdjxjrRdxHbG0wmUPv9okcLy
         tsrEkHnNVihWJG3B7hHQYOiu4VWGgvE5/Qlr0VLpVDFGyq7dh151ZzfVE2BlhAxELlM9
         Ugx2mBsLgjAQ0wVZP56L6XMQ8An1ImlOv2NyVkzgW+yTNqw/oNMsVYEKJKiBWp0ZIATc
         btuQ==
X-Google-Smtp-Source: APXvYqx+O2zhw9nqX0Tty1pE8nk9mqW7tG4M02tzrHheb4GGaHqrHGBb08mJs1QVYCGzh6Kd7EqRcAOVKWXsuQGBwbo=
X-Received: by 2002:a24:5094:: with SMTP id m142mr8967439itb.96.1559158096656;
 Wed, 29 May 2019 12:28:16 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com> <20190529180931.GI18589@dhcp22.suse.cz>
In-Reply-To: <20190529180931.GI18589@dhcp22.suse.cz>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 30 May 2019 00:28:05 +0500
Message-ID: <CABXGCsMTHHfkCaKRcgjAPc2kOpcwi0G=cX8+mf9XoKY1RGTc=Q@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 May 2019 at 23:09, Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 29-05-19 22:32:08, Mikhail Gavrilov wrote:
> > On Wed, 29 May 2019 at 09:05, Mikhail Gavrilov
> > <mikhail.v.gavrilov@gmail.com> wrote:
> > >
> > > Hi folks.
> > > I am observed kernel panic after update to git tag 5.2-rc2.
> > > This crash happens at memory pressing when swap being used.
> > >
> > > Unfortunately in journalctl saved only this:
> > >
> >
> > Now I captured better trace.
> >
> > : page:ffffd6d34dff0000 refcount:1 mapcount:1 mapping:ffff97812323a689
> > index:0xfecec363
> > : anon
> > : flags: 0x17fffe00080034(uptodate|lru|active|swapbacked)
> > : raw: 0017fffe00080034 ffffd6d34c67c508 ffffd6d3504b8d48 ffff97812323a689
> > : raw: 00000000fecec363 0000000000000000 0000000100000000 ffff978433ace000
> > : page dumped because: VM_BUG_ON_PAGE(entry != page)
> > : page->mem_cgroup:ffff978433ace000
> > : ------------[ cut here ]------------
> > : kernel BUG at mm/swap_state.c:170!
>
> Do you see the same with 5.2-rc1 resp. 5.1?

On 5.2-rc1 I has another another issue
https://www.spinics.net/lists/linux-ext4/msg65661.html


--
Best Regards,
Mike Gavrilov.


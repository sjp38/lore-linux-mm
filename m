Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50CC3C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:56:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10100206BA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:56:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="mVcQ2Wr9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10100206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9289E6B0007; Tue, 16 Apr 2019 14:56:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AF3F6B0008; Tue, 16 Apr 2019 14:56:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 777286B000D; Tue, 16 Apr 2019 14:56:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 442176B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:56:34 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id u10so10442347oie.10
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:56:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hd6YYQ3v11Q102JhxXilIcflTiefu/2D26xYyg0/qvg=;
        b=H2Jzbi8nrBE+9es99Tg4mWxCqdmSJusTGGaZ6CTe6jJRt0JOxzvDqAHaQyzBpW/CKk
         Ygmslx4E7KLH6D5w26etgo7kM5Wq1Vryqw4t9AU6hJbsieuerR+gk4EfVeP+T24nSXXC
         9Xw3ZNcPNfb0J4z2kTbqmYsUwAkxm0rqI/QiGDcDUYLCDaQtzE+INWpliCK9Is26VnVx
         Aw4tD0ce/+dA9V3Bze5GnshWktJhnMkLjzSmsUsosjGyuhNLDNUTTlE6RCJyMH0/gGLV
         lKb3ptDFKHCQwnD0Q8+0MfMEtVxK2mfGMZCWfuCkepCLs9pN7KDs8LR9uTlINkPJ3Ip+
         nCXw==
X-Gm-Message-State: APjAAAWyKYItDiqoYXNTnleskMz+0iL/Uezu9cVrkfO2rKa6Aw+pmKtv
	IgSYqno/ntLrgNd2j6F1g3SGe9WcsOkofZWouoTYQ/5rZIYgF47xVfpdUe4HiE+16R6a/waX9ZE
	cZkx95NGBrCaTl9ZDRT8lgi6A2sPKMzvWV6C208ViH+Ly3UUgvDbpfZq4Ebj3SYaJ3A==
X-Received: by 2002:a9d:3988:: with SMTP id y8mr53206132otb.231.1555440993899;
        Tue, 16 Apr 2019 11:56:33 -0700 (PDT)
X-Received: by 2002:a9d:3988:: with SMTP id y8mr53206095otb.231.1555440993103;
        Tue, 16 Apr 2019 11:56:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555440993; cv=none;
        d=google.com; s=arc-20160816;
        b=E4g2Qaok+FQTJlM+7iuiKI6kkWoNYyyQXZZcQDF8ysKI58XNNb3LCyr/H15rLQP3S1
         G3OaqdfHrfAXpD6OvriEHlanyWme5F0tX+fvhHfamK7H88rNrf/wv4ewx/MCidu6WAtI
         1Orzgg9uGo/zAWLIOFzJ85lu0L7Rp01RCfN9q0bI5McqsdGBq9y87hFldU0lwj0VIW4v
         qIgLhr7baT8p0G0NeJKOpkVpECOLB1c+kDzJuov8CYvmvqturG6x4xM3F57x9AOqw514
         2/e4l4QYE9Zzegd04VhNLB010H5ihO5mp+JEzl+JJ12JLPZci+TFgX1lWAfxaQMgsB5u
         hovA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hd6YYQ3v11Q102JhxXilIcflTiefu/2D26xYyg0/qvg=;
        b=yIMo1O2rUwflMP8kqOJb0tIs6AfJinndcFrILGDt97yEewwpwsMhMW6B7aIgMyiZCJ
         NsNwBGTyVafxUrPzMzuhWGAV+kP2+LUqsYbdof1SKAOKnJZwqfA/+gYMv3fkTfJR4l/6
         wupOz8PG1F/C160AB3FUQx1sM5t/6CBm4b4k+MQnNno1OLFlNAj8SogcIXhYr3IZ80XK
         g/2Y0/iHoW8EpCr5evIM/+mf8okIEWVbNMeSRWXdUuICR9Hyj8eO+PKTfEgr3EC8YJK3
         SeQTcLnOg2UriJQPBML+K1cxVyXxl5y3dvLpAShYr5FhrfKLPEVNi9OpLyScX73vkTiy
         shDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=mVcQ2Wr9;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor26691997oib.165.2019.04.16.11.56.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 11:56:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=mVcQ2Wr9;
       spf=pass (google.com: domain of trong@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=trong@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hd6YYQ3v11Q102JhxXilIcflTiefu/2D26xYyg0/qvg=;
        b=mVcQ2Wr9m9exR/ADm+8pWn+2G+7anyuu8bmTfoMGizO2ZSTTgvDDH+Ys1aus/m0irL
         HLD71ccNVozch8SMoiY0HhUmsckNjOYVeUG5jhzEpe8gkiq3ZQ1sYmtG1xYwZ1tsIx3+
         Db+maTwVua7KGT7FtqmjM3Kd6ZXgpnVOB1BuT8psnZiRGm8D7tlYRKYEx2HM9RXojzyZ
         yFgfWYTbZ+U4CgoT+fC3RDNME2Zb2ItZMprPbcGesvpuEzbvByfx6sLaC6OSz7oAiSzE
         xR6uBXe3bitD8guNe2dnOiYbNxLaA3RSPoyRTyKngTQAtCdKsd8GqjqE9qIg4XlvYRdB
         0yKw==
X-Google-Smtp-Source: APXvYqyof3rRxq8JcY/+UyB5ka2SU7k7Ud9CzBYhFIOjtp6+4fm1P94K7C5lJZgZxUuKEgOBrh+Cv5KHLS7VYiKyxjc=
X-Received: by 2002:aca:3f07:: with SMTP id m7mr24154237oia.179.1555440992614;
 Tue, 16 Apr 2019 11:56:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190415142229.GA14330@linux-8ccs> <20190415181833.101222-1-trong@android.com>
 <20190416152144.GA1419@linux-8ccs> <CANA+-vDxLy7A7aEDsHS4y7ujwN5atzkGrVwSvDs-U3Oa_5oLFg@mail.gmail.com>
In-Reply-To: <CANA+-vDxLy7A7aEDsHS4y7ujwN5atzkGrVwSvDs-U3Oa_5oLFg@mail.gmail.com>
From: Tri Vo <trong@android.com>
Date: Tue, 16 Apr 2019 11:56:21 -0700
Message-ID: <CANA+-vAvLUFPhfXj_CxkV8Fgv+zmqvu=MxwtwFTbr5Nrn68E9g@mail.gmail.com>
Subject: Re: [PATCH v2] module: add stubs for within_module functions
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Desaulniers <ndesaulniers@google.com>, Greg Hackmann <ghackmann@android.com>, linux-mm@kvack.org, 
	kbuild-all@01.org, Randy Dunlap <rdunlap@infradead.org>, 
	kbuild test robot <lkp@intel.com>, LKML <linux-kernel@vger.kernel.org>, 
	Petri Gynther <pgynther@google.com>, willy@infradead.org, 
	Peter Oberparleiter <oberpar@linux.ibm.com>, Jessica Yu <jeyu@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 10:55 AM Tri Vo <trong@android.com> wrote:
>
> On Tue, Apr 16, 2019 at 8:21 AM Jessica Yu <jeyu@kernel.org> wrote:
> >
> > +++ Tri Vo [15/04/19 11:18 -0700]:
> > >Provide stubs for within_module_core(), within_module_init(), and
> > >within_module() to prevent build errors when !CONFIG_MODULES.
> > >
> > >v2:
> > >- Generalized commit message, as per Jessica.
> > >- Stubs for within_module_core() and within_module_init(), as per Nick.
> > >
> > >Suggested-by: Matthew Wilcox <willy@infradead.org>
> > >Reported-by: Randy Dunlap <rdunlap@infradead.org>
> > >Reported-by: kbuild test robot <lkp@intel.com>
> > >Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
> > >Signed-off-by: Tri Vo <trong@android.com>
> >
> > Applied, thanks!
>
> Thank you!

Andrew,
this patch fixes 8c3d220cb6b5 ("gcov: clang support"). Could you
re-apply the gcov patch? Sorry, if it's a dumb question. I'm not
familiar with how cross-tree patches are handled in Linux.


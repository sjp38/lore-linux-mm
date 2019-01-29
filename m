Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 853FBC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:33:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4044220881
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:33:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xbHcsDb9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4044220881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5EBF8E0002; Tue, 29 Jan 2019 15:33:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0CB98E0001; Tue, 29 Jan 2019 15:33:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B22A88E0002; Tue, 29 Jan 2019 15:33:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED698E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:33:30 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t10so15085574plo.13
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:33:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UmiUSTgSat38Kz5OyIq2+KDdgAO34gIysAfUK3srYEo=;
        b=kaI7TvtdeP5HfB+MwCZjIR3scdFF1DKq9IPHdGtLwloY++PaEHEDtyQvZQOKp1S0ZQ
         ZySCbGDlQATQLfzvCpk39JmUNuV9oCqYUN24Oo0Mcz5bQx7s4VCb95HIZHi/3IbEmyYU
         CcGAsO0x4gA6vrErXfiQT5wz7nUtdL00H/c9yMrSQkSOuXSXikw5uTfM0ItBC7QCycXA
         pXJ1qLi02zzR3Kvgmu9+0pI8I8n8hDckJjETEb75gZi+unDT4qeYO9qj4oQIavsRRREN
         srcxO/60XAkWEWIBoRUmQFtgbSBGQ2ffguN1IunWziuL8ZJuBOBsZT7wUzsQmPsu3Mcw
         oxBg==
X-Gm-Message-State: AJcUukcNGHthTgOuTsxcD7r7X/8ow2hQQFELLhAXtqNLBdiEzOYfn8kj
	hAtxWC+fJ+8TjyWLbubi3fiAbBvIBkVIVtE3YaurzJocYUcYx0a1bcCZYQbLyXqlmH8ClMZk2o2
	bhoVmF2X4CTQcQ+AO2rI9yMwGSV/1aqNHPxsmLUyx/aRKLv5eoGcPkuyIw7SeMmY=
X-Received: by 2002:a63:111c:: with SMTP id g28mr24711355pgl.85.1548794009591;
        Tue, 29 Jan 2019 12:33:29 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6EyiZSPqf2+2nTwyefcHlPXTeVLkVke45KfohRzzgaKUOKxN+db+vXKz+c4m6qXtVdEG4b
X-Received: by 2002:a63:111c:: with SMTP id g28mr24711307pgl.85.1548794008672;
        Tue, 29 Jan 2019 12:33:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548794008; cv=none;
        d=google.com; s=arc-20160816;
        b=vxOhNZrWHjQt4k9Ig3Cg+Y4qiNOSoCMBkiJUBehDqYjhi9oo9BWTbuPqAnhFysGBnf
         7GQQ5mr8QsxaqCBQMx6tqOwvPOHoG7lNk0498R1Amcy7kv2MkLu2EMFSvCDcLRc+8mI+
         j4jjAMv8kKQq3eyMeSqd931xTQ44S3PLdJaEdy9/Pt0tKfkeM8eaUUO7ORug7rGB6a1Y
         hqW+Vku3G4kf2LLw0EYf/TK7SicEArCTo7r4cukzXApVFM/atW+5vddDfxD9gmj+D5lT
         D6AZxcBvBScnosEW2SNz8nR1rryC4iFVVykQAxJQ3hD9OofuRh0ug1MEJFpfX32dqRA2
         1PXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UmiUSTgSat38Kz5OyIq2+KDdgAO34gIysAfUK3srYEo=;
        b=m6SKzzofJlHJrYK0E5scadzbpeyXRBwq52rqPkIzhbUjyqb8tbmxLFnAQFX/ZBJg7e
         R7aLR3hCtGaFW+0/4T6VQhiHo4GqUDrxm56vXLtElrLLRLCaD/QFpwXhIXPwrBj7PULp
         CEKfF5M0IVYjdXi7z6ro3ud5Q/jCqd/ls78vBrNKUcbUkt9IFnupikEcBkMtksGPA+R6
         DdCW+6n6gro3X7rxe7aluR1A+bEpxJYQrfXmRQyhJEqEV8idDlAgrBqH+y3PHZQ3Q8II
         eDeMlJbACaOA4zSQSj+NLGdAvk7Br47i4E0xgdTAqAY/sS8BaGnxRjLVVZv1jHAGxOi7
         F/nA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xbHcsDb9;
       spf=pass (google.com: domain of srs0=yq8b=qf=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Yq8B=QF=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 62si15275802plc.87.2019.01.29.12.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 12:33:28 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=yq8b=qf=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xbHcsDb9;
       spf=pass (google.com: domain of srs0=yq8b=qf=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Yq8B=QF=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C67A720881;
	Tue, 29 Jan 2019 20:33:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548794008;
	bh=DPvH4a8NS+v9FXY+mtxhNvQwoYBsLvv8TgIPjWa/rig=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=xbHcsDb9z/t9SFcX7zbJvN0Y70JVgtoHVnofc5ApZrRHDseOF/6LXOxzrZT/DaNos
	 DorLlUrMHz7AexuNH3hg/+0h8VKG6kaC1S+aSGG36dshtPMM1cb/HFR5bCuFQ7/dEt
	 W2YU8l6kBJBV36AAypIa1G/iJw1Owiz1BwyS+NR8=
Date: Tue, 29 Jan 2019 21:33:25 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH] zswap: ignore debugfs_create_dir() return value
Message-ID: <20190129203325.GA2723@kroah.com>
References: <20190122152151.16139-9-gregkh@linuxfoundation.org>
 <CALZtONCjGashJkkDSxjP-E8-p67+WeAjDaYn5dQi=FomByh8Qg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONCjGashJkkDSxjP-E8-p67+WeAjDaYn5dQi=FomByh8Qg@mail.gmail.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 02:46:30PM -0500, Dan Streetman wrote:
> On Tue, Jan 22, 2019 at 10:23 AM Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
> >
> > When calling debugfs functions, there is no need to ever check the
> > return value.  The function can work or not, but the code logic should
> > never do something different based on this.
> >
> > Cc: Seth Jennings <sjenning@redhat.com>
> > Cc: Dan Streetman <ddstreet@ieee.org>
> > Cc: linux-mm@kvack.org
> > Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > ---
> >  mm/zswap.c | 2 --
> >  1 file changed, 2 deletions(-)
> >
> > diff --git a/mm/zswap.c b/mm/zswap.c
> > index a4e4d36ec085..f583d08f6e24 100644
> > --- a/mm/zswap.c
> > +++ b/mm/zswap.c
> > @@ -1262,8 +1262,6 @@ static int __init zswap_debugfs_init(void)
> >                 return -ENODEV;
> >
> >         zswap_debugfs_root = debugfs_create_dir("zswap", NULL);
> > -       if (!zswap_debugfs_root)
> > -               return -ENOMEM;
> >
> >         debugfs_create_u64("pool_limit_hit", 0444,
> >                            zswap_debugfs_root, &zswap_pool_limit_hit);
> 
> wait, so if i'm reading the code right, in the case where
> debugfs_create_dir() returns NULL, that will then be passed along to
> debugfs_create_u64() as its parent directory - and the debugfs nodes
> will then get created in the root debugfs directory.  That's not what
> we want to happen...

True, but that is such a rare thing to ever happen (hint, you have to be
out of memory), that it's not really a bad thing.  But, you are not the
first to mention this, which is why this patch is on its way to Linus
for 5.0-final:
	https://lore.kernel.org/lkml/20190123102814.GB17123@kroah.com/

thanks,

greg k-h


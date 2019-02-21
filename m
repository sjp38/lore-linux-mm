Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68EACC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:56:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2648620880
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:56:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UtzSOKv/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2648620880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B882D8E0065; Thu, 21 Feb 2019 03:56:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B10CF8E0002; Thu, 21 Feb 2019 03:56:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B1238E0065; Thu, 21 Feb 2019 03:56:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5716A8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:56:55 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 71so19679657plf.19
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 00:56:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VfKdvQKNjhi7GLOZO2B6g+shK7xwZm6nI7j0UxgbSvM=;
        b=SjmK27qc8z2HyGfyiGPnoN3pRSMK/GrPFlE5RvIofYcB88IpqItqMOnhNr3Iyfa64J
         fT/0yhCrkJzq0U40psbXtvpUkahxLGAqrKdrFlh53fxuYQ+px99QxtTHsODDLVza8Kcz
         G9uW5Izl/yI1/iE2MOi1F5QsmhEpRJ3ttW3HpoS7wmLjed3iUwxTUTLQA6G+yQro+1Lf
         Ut8Lc2GtCYS6Lll+rqFYd7FGgJasCHw5VuqLzDiRfHathj84JtFbmCsxjUNwGpk7jV4A
         cL+/cStjOD61q39nxTJnt2NZVs+zKe4E8mXyagqimFm01SM6EEmbSfN9eoxV7T+bRFh3
         dfvg==
X-Gm-Message-State: AHQUAuYoJK/p758ghPH9oR2/oe43OtlG9RFdO+zQGugABlTZ0/iFZhHp
	so7J/x6M3Usahn6iBGjox9cKi84quRF9yup4UDrrnTsBoxm+25Tk7fIoahUzD+PkqQjQ9PBmIvK
	AWAuEMe2044yXbQo2tK9uXXaa32rZdA4bLiGAPOWUWgAUgN6pnXpCldwg3WjRQMo5ft22XktqIj
	sKHH5zbphtwGOyfzgVFLki26L+gk4HAVgIvRafFJ9Vwuy/CDdMZLzEq3i+nx3OtlQ6Sa0k/20mg
	DIuixLBbq3Uu9UpxQuX2p7TaXcdxjc2RJqOmI8KgcE6BJWkjyp8kV+GtWAaNA3nRl9VX+NNxjWc
	6NzV+ROmn+VJ4auwCgTcs9siirCa1oQzv5V9Vl/+4NyC1Uat7UN6psFws2R4ycyZAY3FeoJPkrr
	t
X-Received: by 2002:a63:54c:: with SMTP id 73mr5517143pgf.295.1550739414957;
        Thu, 21 Feb 2019 00:56:54 -0800 (PST)
X-Received: by 2002:a63:54c:: with SMTP id 73mr5517110pgf.295.1550739414278;
        Thu, 21 Feb 2019 00:56:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550739414; cv=none;
        d=google.com; s=arc-20160816;
        b=rABoFDr+j+ZTMH2Ccw50F0hLS8p8MQ93T48tLXGDyeMD/pAy6dDVgk0yDp3nxdtSAD
         f4iw23olAPjOf4ECTzlZp4Y+zCaa8ZJtCqNh7bX29dVqcgH5SoIEVVCsVpKVO3lSqJrc
         ycyKLetKxca6y9UjYlohMgxlM9nu1yiPUu5zMDJ787Qd1j1ESbwy5VTuNlblvq1JC6u9
         H6gDATWqwCCc/xAp+jgJKee5ChUP9htp5ZllpQJ+f80lj6K5ZHIWaZrEP7ZMFsu0heqW
         zH7+Aw4KKA7/9aHxMCejXa+JCtCADVDJkMi3s737rew6rx9RlnsxdXnRLYVqsGZnLQLn
         kSUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VfKdvQKNjhi7GLOZO2B6g+shK7xwZm6nI7j0UxgbSvM=;
        b=VxCHFId3LX57r6KhfBI0FY/D5PLoLnSP6SkcfP5hjFOJvOeWdwLfY1JEHmirE91LZD
         mhl8wDZABHahFx6ZM7Ab8+q9CLE8741OOkx1aaut+/LZmXrstUeSrMGjkrf5wavAvgYO
         tdbtZD6YEEDUXy83oHNwqmQ1MVbPPc0fboyvx/xcjfIIzlsP/vltxcFZN5+4Ik6hr9yg
         xOIF88GwATWL/t6GkqDzQvtk3xeID5L97AzjyPlszI4brXxvSY2yoas02sbqL+ZPdTSz
         Ae7Bh221xqaaE6saqKtaZOFgxIcU6kWxxx9/kgTOPKsT+O3pgf9U0N07iJuDVu4o3anO
         EQlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="UtzSOKv/";
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a189sor35264523pfb.2.2019.02.21.00.56.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 00:56:54 -0800 (PST)
Received-SPF: pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="UtzSOKv/";
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=VfKdvQKNjhi7GLOZO2B6g+shK7xwZm6nI7j0UxgbSvM=;
        b=UtzSOKv/Xh1sDFxxAUXHybgPjqXRzpCOAITL9VzkE581nWD6aM9fjNiyr1SAsHTuRd
         +JXVtMVOSGbagP5TvHwGp/KyKZr/SiMJKpMQkAYT2x4eTtfyRU+urXUn0UbUAEKO+j1r
         MGEdc1mxhzA/q86wVU5/BMdRHefQAK7meLBrqJxv3unkeekGYgkTo8fIPJkpHI+YyezD
         XZDd3i3S1W4CurtkHOxonlMjN3kDnF6ZeboH8KRPc94Zg9tpscAMzN+yIuK/GaMLKoK1
         FyONS6ubj+UxhFssXAxponQXH2cutYksp3PtYtRzFsx1ZsEV/aFJ5ifC229jU41aD5uz
         00CQ==
X-Google-Smtp-Source: AHgI3IbL6FYTY9it2Tkuw/g665IHFia0w3wT+NuMNIwzlbsbqePmwVRN1pFGs7hBrEwccnrPokCPBg==
X-Received: by 2002:aa7:85cc:: with SMTP id z12mr39513394pfn.196.1550739413958;
        Thu, 21 Feb 2019 00:56:53 -0800 (PST)
Received: from localhost ([218.189.10.173])
        by smtp.gmail.com with ESMTPSA id o2sm30314231pgq.29.2019.02.21.00.56.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Feb 2019 00:56:53 -0800 (PST)
Date: Thu, 21 Feb 2019 16:56:42 +0800
From: Yue Hu <zbestahu@gmail.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, rientjes@google.com, joe@perches.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, huyue2@yulong.com, Greg
 KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm/cma_debug: Check for null tmp in
 cma_debugfs_add_one()
Message-ID: <20190221165642.00005d86.zbestahu@gmail.com>
In-Reply-To: <20190221082309.GG4525@dhcp22.suse.cz>
References: <20190221040130.8940-1-zbestahu@gmail.com>
	<20190221040130.8940-2-zbestahu@gmail.com>
	<20190221082309.GG4525@dhcp22.suse.cz>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Feb 2019 09:23:09 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 21-02-19 12:01:30, Yue Hu wrote:
> > From: Yue Hu <huyue2@yulong.com>
> > 
> > If debugfs_create_dir() failed, the following debugfs_create_file()
> > will be meanless since it depends on non-NULL tmp dentry and it will
> > only waste CPU resource.  
> 
> The file will be created in the debugfs root. But, more importantly.
> Greg (CCed now) is working on removing the failure paths because he
> believes they do not really matter for debugfs and they make code more
> ugly. More importantly a check for NULL is not correct because you
> get ERR_PTR after recent changes IIRC.

Same check logic in cma_debugfs_init(), i'm just finding they do not stay
the same.

> 
> > 
> > Signed-off-by: Yue Hu <huyue2@yulong.com>
> > ---
> >  mm/cma_debug.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> > index 2c2c869..3e9d984 100644
> > --- a/mm/cma_debug.c
> > +++ b/mm/cma_debug.c
> > @@ -169,6 +169,8 @@ static void cma_debugfs_add_one(struct cma *cma, struct dentry *root_dentry)
> >  	scnprintf(name, sizeof(name), "cma-%s", cma->name);
> >  
> >  	tmp = debugfs_create_dir(name, root_dentry);
> > +	if (!tmp)
> > +		return;
> >  
> >  	debugfs_create_file("alloc", 0200, tmp, cma, &cma_alloc_fops);
> >  	debugfs_create_file("free", 0200, tmp, cma, &cma_free_fops);
> > -- 
> > 1.9.1
> >   
> 


Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB6BDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 09:10:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96016214AF
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 09:10:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="KetB6Q6N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96016214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 369208E0068; Thu, 21 Feb 2019 04:10:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 317508E0002; Thu, 21 Feb 2019 04:10:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 207E58E0068; Thu, 21 Feb 2019 04:10:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D356A8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 04:10:14 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b10so9461707pla.14
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 01:10:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wrh4/JJhozDWyemVq5UWA9zW0Git+SM1T4dGyGZsVNM=;
        b=t8d1DpQ/jwXMJLjXKP08JJ6dwBDFQFxymKPRu+K/NH7Llhshj/DM8hx+kOsj4ykGim
         8VsMoXG7MWK250yYjbQx8J6P6S3IPuxYcrfPmle8tmdQc6z7JwK/qAgTglsFGCM5WcPD
         shYrb1LapZuGNP47uiNJxz0zhm8V1R4L+Mz/Fab2c9DWJXYKi8nc4HPtTYC3PL+p6qw/
         iYJczf0phvREgIi0TDDdn0j5evkQ6U0rqk0coqd6zioTrE/iOtPWkisYzZSs7YmqKVUq
         tfZiBmUe56krxVyZ91N0wTe9tlRPfrvwk8Iz2fcOtDX2ivKdPKRr26TutXLTZgS2y/Uy
         K9gQ==
X-Gm-Message-State: AHQUAuasMO79P2cUo7Fly0MUbcpqle5ucyFyyH/xhc/D67hykPvo/vA1
	/SkuOvBwW8UfeNnKsN0lkw+Q8KYmqEWRozZ5qb5VC8/3LGsyTG0UYxm43JC9QaiOrStLtnDYhzT
	VE9lWh7+M+NcIqRQG0oPGkCqUMMNWaQluY5YW+nHgGFL6qiRhvRpeklCaqLHjrxo=
X-Received: by 2002:a62:4d81:: with SMTP id a123mr40173939pfb.122.1550740214554;
        Thu, 21 Feb 2019 01:10:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZAjWagx3rPkcxlIk0xck8vwkVqf0GdD5WLnbQZdbNl4Nww7+ltYdIzjhG8Cf0romVEfa9t
X-Received: by 2002:a62:4d81:: with SMTP id a123mr40173881pfb.122.1550740213790;
        Thu, 21 Feb 2019 01:10:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550740213; cv=none;
        d=google.com; s=arc-20160816;
        b=WH29hIsPY6JwPm2QZwCLAYHpckhdFEikLlmUWYy0Ur6TNapwIECwjRZuHxmsqsHlp9
         ntu6X+niGQj7zPo5RspYqtezDuz7eaJkVJGFMQQAdpMytpB6Ap3aiHjXhKAZBOM7q2zp
         qBHze1kPicQ70JS6lhPU/TUQgWoBXBDqZ/G3nE5HqKFJri+GIzwNUsbsx0Jac9MeUiXZ
         AQHmMT/LWOPxyuW6ovoJ8DROeKoK7vpbS7THaTrguxJ6C733T9rg6WzffoYRI4xWENp4
         oj+QBg0QX4oGRDxVIFojkOEJx/wUyDoGAJHeDmiXMGlocHasyxMgZrtlm8mGse1swvPA
         VFtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wrh4/JJhozDWyemVq5UWA9zW0Git+SM1T4dGyGZsVNM=;
        b=KmMQbe9tCUdXhLQLLJn1hNM/BISKiTJ2txtZMb3C7FNm5G/8kblx1GGTddTMHeRZmI
         QyyPH0LAcCjX/45pjpl2HLnmClAutI7PIWWoxTKdMZY+fXQq0eQdC6new5ZfPsRJA8HJ
         bSLYshCHTJthCYqFiHOUU1k93f1F+4DMLK8S38sOcI7bEcno+uxUZxs8CjUy2zl8OY0k
         ppzUe4C57togqTEWmbTEcd6zU9r+cscnuB5bFApynUAroo7DVzhSoU32jqiHjQJFY3Ht
         6mow0dIMjAcIbYXV1cDmKCkOn8Obhtmla8j6/Wsph7Kt4dHtFPgYhiU2VcIf/h/h6EGj
         DHIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KetB6Q6N;
       spf=pass (google.com: domain of srs0=u/6v=q4=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=u/6V=Q4=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n15si20462396pgk.27.2019.02.21.01.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 01:10:13 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=u/6v=q4=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KetB6Q6N;
       spf=pass (google.com: domain of srs0=u/6v=q4=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=u/6V=Q4=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1B7302086C;
	Thu, 21 Feb 2019 09:10:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550740213;
	bh=s8S79TiwSNQPycQI9tlCN5pynyKc8OhiDbHfbeClHHM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=KetB6Q6N+4/P79febiDQ77mYAT4JEczdD/6MzfbbnvpaFL41pSGerqEuD+AoBpEPO
	 nXEKjzwTqqANnIWMhK5oToDJzomCHyQ1NqdyeUKQxG8UPpN3WAyHB6iL44rCVLUqpF
	 8I8Sno2SUe1yW2MiJdTcB+K24hwUdG/mSGb2XmH8=
Date: Thu, 21 Feb 2019 10:10:10 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Yue Hu <zbestahu@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org,
	rientjes@google.com, joe@perches.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, huyue2@yulong.com
Subject: Re: [PATCH] mm/cma_debug: Check for null tmp in cma_debugfs_add_one()
Message-ID: <20190221091010.GA11118@kroah.com>
References: <20190221040130.8940-1-zbestahu@gmail.com>
 <20190221040130.8940-2-zbestahu@gmail.com>
 <20190221082309.GG4525@dhcp22.suse.cz>
 <20190221165642.00005d86.zbestahu@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221165642.00005d86.zbestahu@gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 04:56:42PM +0800, Yue Hu wrote:
> On Thu, 21 Feb 2019 09:23:09 +0100
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Thu 21-02-19 12:01:30, Yue Hu wrote:
> > > From: Yue Hu <huyue2@yulong.com>
> > > 
> > > If debugfs_create_dir() failed, the following debugfs_create_file()
> > > will be meanless since it depends on non-NULL tmp dentry and it will
> > > only waste CPU resource.  
> > 
> > The file will be created in the debugfs root. But, more importantly.
> > Greg (CCed now) is working on removing the failure paths because he
> > believes they do not really matter for debugfs and they make code more
> > ugly. More importantly a check for NULL is not correct because you
> > get ERR_PTR after recent changes IIRC.
> 
> Same check logic in cma_debugfs_init(), i'm just finding they do not stay
> the same.

I have patches to fix that up as well :)

thanks,

greg k-h


Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 102B9C4360F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 11:04:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1D6D2186A
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 11:04:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ky1660ZF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1D6D2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 602DD6B02E9; Sun, 17 Mar 2019 07:04:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B2BA6B02EA; Sun, 17 Mar 2019 07:04:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48CB26B02EB; Sun, 17 Mar 2019 07:04:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0374E6B02E9
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 07:04:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o24so15393283pgh.5
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 04:04:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DAUO866U+LyT/fGZXDGVGL3pFhqlS5OamVnN28Td3iw=;
        b=dzljhwESK/ploVTfYx5VV3dg7B9uMnVYgOHnQSBtZEgTSZBDFqeJSrdIi0vDxHk6XV
         KdNBCeCcnyDCJ3rtCah6T+p7S3BOxb5IKAVoxlvFuVXZIoC7a4Wbu2n3IhagD9OghgXg
         9qqAhVXJs/4bw22EtVt+e6Onq57+uK559X5W8FyeAABv8sYZJLPeJohf4Tn+FrGIJtI+
         qXk56ajWqsJ8sa6dwJjx1xp7zpwx22emwRCOJA8fPLdKZCAGvWZk1FcNREornanc9yG/
         XKZV2gxOAW+NFpVXjOUyKPiy07ovj8Ofho8I1w2Bx86Nf8LEwmqr3nLUdo9+Jq8R8ASO
         ACBQ==
X-Gm-Message-State: APjAAAUYWUzJIGzzuZGOHPPYUSt16tptVHW7fZP4J0TXnPrn6eoqqsUW
	xmd25fzqsonoYuW6QV0omw9CtijWdRv/MWPnbmTK5NDnsrKK+x+rvHLI8ew6afV3L3WDaHEybZD
	r/iB8Aewv2BvRIPCgNjplaQOkQXjswdYqEZS94lWDhlVT/apHFAQUEdg1+ibShG0cyQ==
X-Received: by 2002:a62:ea0f:: with SMTP id t15mr13793979pfh.124.1552820691581;
        Sun, 17 Mar 2019 04:04:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMJ+EVlibxAssYQ8mslfhI9YXVeU8jkDe+yEWEZ8vqVxsC67kpn7cZ+ntn+PYSn/S8pYRC
X-Received: by 2002:a62:ea0f:: with SMTP id t15mr13793906pfh.124.1552820690548;
        Sun, 17 Mar 2019 04:04:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552820690; cv=none;
        d=google.com; s=arc-20160816;
        b=jRqhncdy2R9MvNzReN/eC/2rigywgTqYmCAvVrkWVsB2SOAhL0vep/qGW/gnjDClNr
         6Kc9N+kQvNwz5yRZVaBFJnmgCWPzlfyPClDAW8jBfgy4Y6DrQ7eIxyeubJP9luzqZmx6
         mL8Z5gDJW7OYCS3IIKjUouqsRNgvfBVdtqUkDkFlKpFukPLuFpZnUI2WWCBbFZAIm47w
         1LH+D0h95cZOGxIVvWkIJ7czF/hz45NSG1QnmTd8uorQCYDdOR7IutHS0L8mHYH4P5Hl
         hQZI6DsUXl0KSgh1cX4LnAuMmOUPb/feSyWbt3gx+fwnjzqzShhiIrZE/c16+ToSTza9
         2uAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DAUO866U+LyT/fGZXDGVGL3pFhqlS5OamVnN28Td3iw=;
        b=x8LPMNyddj4f5mw70vifb3Y1jO0PQjbQ0KOTl/p1MMZSTDo/DqpQ1Ym2dMskBk6Yfi
         oKaNJMbhKWNbJEtbqaEkTUUXRYqiIdLmerygvELNj+ZtrQj3xRrMfVgH9Ed7OkfYo3V7
         Hvd349Uqxo+28Q1Fh4vaw7fLZWg2VPZmNsPXOH397wamzU4ypBqez0/NT3UHYUUv/gkJ
         KjFZVTiiubAj1C0hQV5mKnh3veA2gSs6LLXOY0A0r/iq0K8rANYOBQtyC64AH32ZxuwL
         zKMRcWQK9A0wapOpCxUfG5t+whx63Y9kEtqMkFeS5rzB/pBQOoamZw/9HSs8dXlaQHwf
         fnSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ky1660ZF;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z13si6392030pgv.508.2019.03.17.04.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 04:04:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ky1660ZF;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 53BD221019;
	Sun, 17 Mar 2019 11:04:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552820690;
	bh=Ly+J4Z6Dq25YOFCa/OR3v5B01n9/VzcGTcpISwqf8L0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ky1660ZF5IxRYo3+e93lTKzAkVsPxlxhT+j/f51FHnIctlZGL5a+JjcFSv6mLBxVo
	 awsVMkrnM6QxycAUk8YyhRmj7uqDapyinZVkW7kViogWxE0Wbg/v5Sclspoioo0PQH
	 LrxpgScU/GEdSh51tbK+6wnJ/3SuMZUlxsaoRA/I=
Date: Sun, 17 Mar 2019 12:04:47 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: syzbot <syzbot+111bc509cd9740d7e4aa@syzkaller.appspotmail.com>
Cc: bp@alien8.de, devel@driverdev.osuosl.org, douly.fnst@cn.fujitsu.com,
	dvyukov@google.com, forest@alittletooquiet.net, hpa@zytor.com,
	konrad.wilk@oracle.com, len.brown@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@redhat.com,
	peterz@infradead.org, puwen@hygon.cn,
	syzkaller-bugs@googlegroups.com, tglx@linutronix.de,
	tvboxspy@gmail.com, wang.yi59@zte.com.cn, x86@kernel.org
Subject: Re: WARNING in rcu_check_gp_start_stall
Message-ID: <20190317110447.GA3885@kroah.com>
References: <0000000000007da94e05827ea99a@google.com>
 <0000000000009b8d8a058447efc5@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000009b8d8a058447efc5@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 03:43:01AM -0700, syzbot wrote:
> syzbot has bisected this bug to:
> 
> commit f1e3e92135202ff3d95195393ee62808c109208c
> Author: Malcolm Priestley <tvboxspy@gmail.com>
> Date:   Wed Jul 22 18:16:42 2015 +0000
> 
>     staging: vt6655: fix tagSRxDesc -> next_desc type
> 
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=111856cf200000
> start commit:   f1e3e921 staging: vt6655: fix tagSRxDesc -> next_desc type
> git tree:       upstream
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=131856cf200000
> console output: https://syzkaller.appspot.com/x/log.txt?x=151856cf200000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=7132344728e7ec3f
> dashboard link: https://syzkaller.appspot.com/bug?extid=111bc509cd9740d7e4aa
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16d4966cc00000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10c492d0c00000
> 
> Reported-by: syzbot+111bc509cd9740d7e4aa@syzkaller.appspotmail.com
> Fixes: f1e3e921 ("staging: vt6655: fix tagSRxDesc -> next_desc type")

I think syzbot is a bit confused here, how can this simple patch, where
you do not have the hardware for this driver, cause this problem?

thanks,

greg k-h


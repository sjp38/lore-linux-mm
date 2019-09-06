Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1331C00306
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 02:50:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A515F207E0
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 02:50:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o68Bclrx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A515F207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E016E6B0003; Thu,  5 Sep 2019 22:50:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB3176B0006; Thu,  5 Sep 2019 22:50:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA29E6B0007; Thu,  5 Sep 2019 22:50:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0129.hostedemail.com [216.40.44.129])
	by kanga.kvack.org (Postfix) with ESMTP id A91536B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:50:28 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 57E1A824CA23
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 02:50:28 +0000 (UTC)
X-FDA: 75902967336.12.uncle08_212d5fe23d538
X-HE-Tag: uncle08_212d5fe23d538
X-Filterd-Recvd-Size: 4290
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 02:50:27 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id q10so3312158pfl.0
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 19:50:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=VgjVGE6lmfxhygBnBRcl9Vrz9pus5n253xhtFVc0NKA=;
        b=o68BclrxtpBqJvfD6tSNsOFflIRQ/l2ADb5wWCZzJFChRYr6SktchPaV1FNPE8jsaq
         nS1tdR7qtKYNTi4a95CJW5tOvBGQ7Az5OmBlRAbJMVp07NepKODC2NDEf+Ke3OkPiZtC
         KzMfZec26XSCrNPUxtNQrTVXVUTZeiWr6w8RNxY/5Bj06hPLduV6m0ZKbpAjoQTXOInB
         KRt5CgZJvv1kLuUgv6j223ouAe8bcR1pi8/KUnaLSenkuN0huOyjSav85wLh2Pr2572F
         peq8dLUF4fxx1mxfUxzUF5Y0N/bMi21gt2QnIFhHhYV253NTJ4WRSOFj0dFwKnnrXfo/
         zuHA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=VgjVGE6lmfxhygBnBRcl9Vrz9pus5n253xhtFVc0NKA=;
        b=ffVDTA7/IWzyYBHhwhdGKDAxXdNzl0p2egz2LVYU1oqdy68CdX8+JTBJS0olx19OgQ
         HT+6spy11vTXiS23vDX514D9zo+Ve2vdKWMSVqvJw91CeRA/h1Tc5Bjf4Wrf8KL2KJYA
         eEeQA6aPQzZwS7ri4QMVpAM/S4NaHAvCG9hZ+n7tYqZKfwYPiFPtOV7IPfMY4ATbTo7Z
         Y8V8ZUpJ0Xv9QtSE2VCPrPp2ekI5ncgfRATZYdY9o2WrqKDSRF66Y5SZuYa6tzV/GIwh
         ISGIXy90MvuAfh8ZNO09+MeCPBePK2d21WOBjS5wRi4GDnMevqcG012Woeb1J6Kx+JQ8
         cyBw==
X-Gm-Message-State: APjAAAU2oIVYM0COCKj4YbY3b1ANh/hYPyfQO8hBG8oSLEKbGuXi+Efu
	SRvus1O6JXQKkDhI1TIxPU4=
X-Google-Smtp-Source: APXvYqyh56I11YbI0Ls757lx16cnPwBBUbXbnLk+XuviLZKkM437vuzYWKlS3jQNm4KSJM77TTynwA==
X-Received: by 2002:a17:90a:2e15:: with SMTP id q21mr7246465pjd.97.1567738226815;
        Thu, 05 Sep 2019 19:50:26 -0700 (PDT)
Received: from localhost ([175.223.27.235])
        by smtp.gmail.com with ESMTPSA id p68sm8147568pfp.9.2019.09.05.19.50.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 19:50:25 -0700 (PDT)
Date: Fri, 6 Sep 2019 11:50:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Qian Cai <cai@lca.pw>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190906025022.GA1253@jagdpanzerIV>
References: <20190904064144.GA5487@jagdpanzerIV>
 <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV>
 <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw>
 <20190904144850.GA8296@tigerII.localdomain>
 <1567629737.5576.87.camel@lca.pw>
 <20190905113208.GA521@jagdpanzerIV>
 <1567699393.5576.96.camel@lca.pw>
 <20190905131413.0aa4e4f1@oasis.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905131413.0aa4e4f1@oasis.local.home>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/05/19 13:14), Steven Rostedt wrote:
> > Hmm, from the article,
> > 
> > https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter
> > 
> > "Since transmission of a single or multiple characters may take a long time
> > relative to CPU speeds, a UART maintains a flag showing busy status so that the
> > host system knows if there is at least one character in the transmit buffer or
> > shift register; "ready for next character(s)" may also be signaled with an
> > interrupt."
> 
> I'm pretty sure all serial consoles do a busy loop on the UART and not
> use interrupts to notify when it's available.

Yes. Besides, we call console drivers with local IRQs disabled.

	-ss


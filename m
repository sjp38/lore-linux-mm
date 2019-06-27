Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F23BDC48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 14:20:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 706AA2085A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 14:20:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ajou.ac.kr header.i=@ajou.ac.kr header.b="r9B3so9K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 706AA2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=ajou.ac.kr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 014288E0014; Thu, 27 Jun 2019 10:20:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F07D98E0002; Thu, 27 Jun 2019 10:20:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1CA18E0014; Thu, 27 Jun 2019 10:20:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC5A88E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 10:20:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u21so1655881pfn.15
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 07:20:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:mime-version:content-disposition:user-agent;
        bh=DS3za/krG7KxyBJ+vG2zjVXj6XDJlFSRs9NVZVEF+Jc=;
        b=PSGo/E9A7eG5E7+AR+m1hrkBeAWUoPA1jGIBZ+bf01w6scSnl8HSH8dCBu95R239RZ
         RPabdRO4kKCcRY3Elmwejbbv1G7uZ8OeJBk81D00TxZqw6Iy+u2Y2Zvit1B4pOsXaNFt
         nOgOgjpTcqk7oPcEXKy9UCFy+NZXsq/27LT7JctgoPV2QAhY8u8dkInf/+CfVcTWq0QC
         dX9pVJfQBIx07lFrUHPGeT/HIlDhmTZ7+luCU/e0iZ7Xk/l5IxlwYWrgI6DHlGpttlY9
         SyTsH3zFZczE8dk3uc52yUjhRTcEELnVlY+41iFQO2rWOoxgMUqCfV71a/GsTnLuyYD6
         bzNQ==
X-Gm-Message-State: APjAAAVzCvhr46INN8d8icBFvrgirod03xgZRBmA8jNYXvux2vaP9F7F
	2lxSzzd+FyToZrHm3YgbnXTf/UcHYniRX+Xng10Fse5QlO6MhTCo7smaRzdVwn94th2OrGy27Z7
	gDH1tGcUxp3t5xKU5/O7efuzJvGqALt4+dqoVoBnDsh8/ER7RHDIyzDI7cKG/NRisPA==
X-Received: by 2002:a63:a61:: with SMTP id z33mr4080100pgk.154.1561645201080;
        Thu, 27 Jun 2019 07:20:01 -0700 (PDT)
X-Received: by 2002:a63:a61:: with SMTP id z33mr4080011pgk.154.1561645199983;
        Thu, 27 Jun 2019 07:19:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561645199; cv=none;
        d=google.com; s=arc-20160816;
        b=ztndXeoJUSAicM1nsgcZXMRY4AUaq8yEu7QIX19hhW8COEX+dVEnBCWrE0XVAtWNb3
         vpcu2MLs/fGu9ErdfXMvCVLsTDD5L0uDUn3chgKhauiy3TSNN6dJL0Ip72JxYnuWjEHX
         ukIy4i01aOaAeiLmNyl/mSxnPgjKopIkeq9lzClhQR7PUefVEuhJoqLue8zZl00+x53o
         E2vSqiy3z2x9j3ISCYYfcqcdj9ovS9Q09x+wo+arYtX9yCJIY3BDAZzy6qzRcetaOJI7
         vq0yWBAwK5velQWAN6XAf3b3fKWfJEwv6UvS5J8pvtw+USxvQi/ZUEQKc2Al/77OU0Ao
         La+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:reply-to:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=DS3za/krG7KxyBJ+vG2zjVXj6XDJlFSRs9NVZVEF+Jc=;
        b=qVI0hSrk9RFqh8cT+r9Ryx/1xaakcDkNVMs4uQf3KvXaXSLolRNft4ZfymzmVZzvkk
         tT9MgDraQgyRX7MyC066BzsvdYCRrrVF2riTMzD1bBXRQe1gXuiyIz+2JVniWvEilGAc
         5SxH0nb6PmutMu/w8AOul+j9nefwQKLH8gspHf1XU9AoX+H+6v9dIuR+8g7Fbfs1SrdV
         R+Zjb4HRJOJPLA44/mcly67cQS1DMBHTPC9mdGWouhtQdJ55o70S2j6InZg0cd2mN5Mp
         gRrCMs8+Ow2aqvAWZxCUj93h4AV4HGIzoi18WDrCNaUNro7w+1qCsD2bQfXVp37QfVcy
         egEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ajou.ac.kr header.s=google header.b=r9B3so9K;
       spf=pass (google.com: domain of heysid@ajou.ac.kr designates 209.85.220.65 as permitted sender) smtp.mailfrom=heysid@ajou.ac.kr;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=ajou.ac.kr
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h63sor6700759pjb.6.2019.06.27.07.19.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 07:19:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of heysid@ajou.ac.kr designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ajou.ac.kr header.s=google header.b=r9B3so9K;
       spf=pass (google.com: domain of heysid@ajou.ac.kr designates 209.85.220.65 as permitted sender) smtp.mailfrom=heysid@ajou.ac.kr;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=ajou.ac.kr
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ajou.ac.kr; s=google;
        h=date:from:to:cc:subject:message-id:reply-to:mime-version
         :content-disposition:user-agent;
        bh=DS3za/krG7KxyBJ+vG2zjVXj6XDJlFSRs9NVZVEF+Jc=;
        b=r9B3so9KeqHB31L9rVmF4vuh18nVz3VoLtGF08ErOmCDRGNAisbfK3wENgybKkopPg
         c8oOZmEaO1Zy+/ZKUFoYmss7HowrERdHcuiqHe/4Xss220BKXSUJvyUD5zHckVfCGY4j
         FoXKO164k1eaRbf0mW50PwafBp49lmCQ9wnr8=
X-Google-Smtp-Source: APXvYqzZh58WAjM35iRVq/24lIXhmNrAYGmKbsGJYRTSPL4KhwnLGeVRaC4wKkhs4jOiYbTEdl5s9Q==
X-Received: by 2002:a17:90a:9201:: with SMTP id m1mr6470756pjo.38.1561645199447;
        Thu, 27 Jun 2019 07:19:59 -0700 (PDT)
Received: from swarm07 ([210.107.197.31])
        by smtp.gmail.com with ESMTPSA id bo20sm5056527pjb.23.2019.06.27.07.19.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jun 2019 07:19:58 -0700 (PDT)
Date: Thu, 27 Jun 2019 14:19:53 +0000
From: Won-Kyo Choe <heysid@ajou.ac.kr>
To: dave.hansen@intel.com
Cc: jsahn@ajou.ac.kr, linux-mm@kvack.org, linux-nvdimm@lists.01.org
Subject: A write error on converting dax0.0 to kmem
Message-ID: <20190627141953.GC3624@swarm07>
Reply-To: heysid@ajou.ac.kr
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Dave. I hope this message is sent appropriately in this time.

We've recently got a new machine which contains Optane DC memory and 
tried to use your patch set[1] in a recent kernel version(5.1.15). 
Unfortunately, we've failed on the last step[2] that describes 
converting device-dax driver as kmem. The main error is "echo: write error: No such device". 
We are certain that there must be a device and it should be recognized 
since we can see it in a path "/dev/dax0.0", however, somehow it keeps saying that error.

We've followed all your steps in the first patch[1] except a step about qemu configuration 
since we already have a persistent memory. We even checked that there is a region 
mapped with persistent memory from a command, `dmesg | grep e820` described in below.

BIOS-e820: [mem 0x0000000880000000-0x00000027ffffffff] persistent (type 7)

As the address is shown above, the thing is that in the qemu, the region is set as 
persistent (type 12) but in the native machine, it says persistent (type 7). 
We've still tried to find what type means and we simply guess that this is one 
of the reasons why we are not able to set the device as kmem.

We'd like to know why this error comes up and how can we handle this problem. 
We would really appreciate it if you are able to little bit help us.

Regards,

Won-Kyo

1. https://patchwork.kernel.org/cover/10829019/
2. https://patchwork.kernel.org/patch/10829041/


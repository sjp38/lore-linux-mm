Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14A6FC18E7C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 02:10:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9F67217F9
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 02:10:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="KIGFNpsD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9F67217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EEFD6B0003; Tue, 21 May 2019 22:10:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C5B76B0006; Tue, 21 May 2019 22:10:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DC356B0007; Tue, 21 May 2019 22:10:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18B496B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 22:10:53 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id u11so386045plz.22
        for <linux-mm@kvack.org>; Tue, 21 May 2019 19:10:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RVmoZC3/WwvW7DNufwo4WuA5HxB5+/gVkqe4H16ZSn4=;
        b=VW8DgXmw8EgetO6SJwLt55TH23rZwmOBChl2pVG6AII9ulapWkra0c0Zvd9VokpYKb
         cz121B/8Ttviosjkb3aSn266tdjZwNnoQc6Uf/9MWDpcASFerZ7fXhVt2cGREkzteMIt
         IjCBRvuwYCNFzNwM8Iay/12giGQU7YOHYCVP76nnrRL3+mRRMm26L2gQyWsQjv0UWduJ
         5C0snACbST83c5Bl8IkxmYpU/7O8VayB5N+bMrtrzajkoF1YSV+ALh3bmsX70dz5kORI
         FrVPZAeSzkNWp+BjKk/0FK/wbssgDsUQGYp3tbgx/iaGirvE7NFnTa63hVywsH0CylA2
         FJeg==
X-Gm-Message-State: APjAAAUqeolDwyN4j3799DhL9mjKtOnpWKybc8jMqQNFVxA5Dg16XWs2
	WzMLs9tVcIrN3E7045buDARN5Nu8OZhNs1SlYiLQtxZOUV0hWhniBSWbCe0p1ZMGScIqJtxZ5kp
	rEV+4KzhotKrs/yZvQlqYoOjXIQFEYEBd2KTpy0FyMTxppZclWcAmIDU7cXBNFYAsKA==
X-Received: by 2002:a62:ee04:: with SMTP id e4mr28532112pfi.232.1558491052682;
        Tue, 21 May 2019 19:10:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEwqIFYB5+GWB20m715qxtmlKHD0VpnLx1YDkLWP+x46UF67p/BcODFX0IpvCt02oATE/z
X-Received: by 2002:a62:ee04:: with SMTP id e4mr28532024pfi.232.1558491051841;
        Tue, 21 May 2019 19:10:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558491051; cv=none;
        d=google.com; s=arc-20160816;
        b=YjKqadm6RmBfKIVJJnHEsAgCakWWcu5kkNOJz0ofKAB2feXyJ87Ofb04fvn3+LIe9y
         qew2n1Gu1iOkltcA+C9g0kQy3eHvtVvTTgtpr8E4MP5rkBWF8OiF/VqVMkxq5uG/7A9F
         2dhavtJYEf8lxwTcCuS76C9gSjakp45b8TAzvig90JLWNrnYXFymZtQ2NEN6FPHzXIwD
         wXC1GeuuxQ+tErdnO0XzbzmB0vIOQ0THsT9eQ1AOTC3hT0HNLo9+lnh4gsQhzhkZx4xA
         ueMl8qvaTW0O0sMDtxm0wBgbyJwhhBX9OEOFtNaCrgB0DF7GYO5x/wUO+0TIgcb2JDkw
         kKjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RVmoZC3/WwvW7DNufwo4WuA5HxB5+/gVkqe4H16ZSn4=;
        b=oNmPogKrvT/m7quNZEns0AVG3kiklHMApJMOqejM1iStisjWVgKVRn20PJdYFMW4Lw
         aJ8nw5iRb7dVjjzy186PPDgD2coPbC0Ad6J5Uto+1m/jvWl5z1jxH5zkgj8+GMgyBgya
         q97BJGp1TwdI0ANvrUarX8SwDR9p30q8Ycv9KPYVBVAsjIKk5KxMBfz1JmK2ouLzgcbC
         wUdqUP1abVaCsQQjFFnQBIxR75YjQoe1W+uqM3Q/65N3d9wD/SbDkmBVIuWjwn6tMeBd
         HXzvm7R8LvQwZbPg71skwwrwJZ1VndhjKFkF4v3qa/a2P3wQ0HO2yMuc1QRmCc9DxQFk
         K07w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KIGFNpsD;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u188si2642507pfu.228.2019.05.21.19.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 19:10:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KIGFNpsD;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 157A6217D7;
	Wed, 22 May 2019 02:10:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558491051;
	bh=1ih48PI12kkUWV1gxUVEAlub4RsQgr7FS/vJ1I+lyVA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=KIGFNpsDdLIOqnE7XDF5rYo0tqQY9FfacESF9YLB4BPT4od6Lx5POSWD/pxhrNCaR
	 BW4MvmqV471h3ck5LHF2z+9/OEZDNUkx7X+Q2qbEI2Dxl3wk+mxwFqhLm8KAZqf5ZB
	 X6Z7JKA9ePiZfYMjNNaurLH1DEAuFC+nrdqNbKnc=
Date: Tue, 21 May 2019 19:10:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Marco Elver <elver@google.com>, kbuild-all@01.org,
 aryabinin@virtuozzo.com, dvyukov@google.com, glider@google.com,
 andreyknvl@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 kasan-dev@googlegroups.com
Subject: Re: [PATCH] mm/kasan: Print frame description for stack bugs
Message-Id: <20190521191050.b8ddb9bb660d13330896529e@linux-foundation.org>
In-Reply-To: <201905190408.ieVAcUi7%lkp@intel.com>
References: <20190517131046.164100-1-elver@google.com>
	<201905190408.ieVAcUi7%lkp@intel.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 19 May 2019 04:48:21 +0800 kbuild test robot <lkp@intel.com> wrote:

> Hi Marco,
> 
> Thank you for the patch! Perhaps something to improve:
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v5.1 next-20190517]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Marco-Elver/mm-kasan-Print-frame-description-for-stack-bugs/20190519-040214
> config: xtensa-allyesconfig (attached as .config)
> compiler: xtensa-linux-gcc (GCC) 8.1.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         GCC_VERSION=8.1.0 make.cross ARCH=xtensa 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 

This, I assume?

--- a/mm/kasan/report.c~mm-kasan-print-frame-description-for-stack-bugs-fix
+++ a/mm/kasan/report.c
@@ -230,7 +230,7 @@ static void print_decoded_frame_descr(co
 		return;
 
 	pr_err("\n");
-	pr_err("this frame has %zu %s:\n", num_objects,
+	pr_err("this frame has %lu %s:\n", num_objects,
 	       num_objects == 1 ? "object" : "objects");
 
 	while (num_objects--) {
@@ -257,7 +257,7 @@ static void print_decoded_frame_descr(co
 		strreplace(token, ':', '\0');
 
 		/* Finally, print object information. */
-		pr_err(" [%zu, %zu) '%s'", offset, offset + size, token);
+		pr_err(" [%lu, %lu) '%s'", offset, offset + size, token);
 	}
 }
 
_


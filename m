Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA740C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:35:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B87620449
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:35:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B87620449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 405046B026B; Tue, 16 Apr 2019 14:35:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B4C96B026D; Tue, 16 Apr 2019 14:35:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A45C6B026E; Tue, 16 Apr 2019 14:35:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D47DC6B026B
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:35:50 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t9so19778570wrs.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:35:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=WQe8M43LEf3D6dp9Ny7bhpUVRfoW7k8zR+S9BDyhw7s=;
        b=rfY+i+cclLzOx4zKU26Dang6VxYOUqUJQAqSt9RLY8+mD5P5FFVJ7Wkj0y0MAm+rIz
         6u1LZ0Y8OQMWrN4g2mbeihbq/x7pgbfUZAcpH98UtfSnh0I0JELvBGn4J7Fdp8Ok/Ofq
         vE+yfPJfdeEi+1VUjeBtOQAjzBTfVP9SkQJ6R4rKN62VHLgxeApzSPVkRdEppxIFG5XW
         RzV7PSrqKoN9o0e5Ztye6/E78GCpbe748EglT0REgAzBd8k1g1ZfrTnkkz7i5DYj+BN7
         yb07tKMZ0xNH0KfV0g/AFS3CAgi2i2BI8S/2KfLH2SEbz4VYmzHNmm/AKBYsD3g2+DlL
         2KIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAW4OVDgg7kYvEInkp72fjC5iPy+E30EVdQxVl3rF1v2VSiOrbXL
	v/uM0fCLi0P5RZeCf+zn7j543WqKznKIihlEsjkb4R4OJvAPRHoqEANNR2liMvdlZK7wp14WyyG
	3Ea0DEw+R1shM2U5xdf730WIS7beHk2P5YOJxEQvOM7wI6Txo1K2FMg5U37vVsmqGJg==
X-Received: by 2002:adf:ee07:: with SMTP id y7mr14730798wrn.219.1555439750477;
        Tue, 16 Apr 2019 11:35:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDeKFTUK4cCU7ZmccFHyFPbSxyjo3etCACsocPwFp8TAqxxnZ/ceq7fGpZTSkNxhB3QeCV
X-Received: by 2002:adf:ee07:: with SMTP id y7mr14730759wrn.219.1555439749838;
        Tue, 16 Apr 2019 11:35:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555439749; cv=none;
        d=google.com; s=arc-20160816;
        b=FLbpHNnNktKDXcG1bxDoFEICuotErbvPyMQsp7VFLR1EuC70MvsAaCsxpWM3oU1F03
         7DXS2MYi5pv1cLndkRcA4H9p2JHF96dZnpgXmq/+bHsTRkOYJ05JKM46cNp9X0RRimFz
         bhjwJ/BlHohdhpS693B7aBpWcbo0V99PdjnhS5sQJF4BV9kSGkcC1TWK2HUouAAsRSzi
         9r6+kl/JWm5g8hqUrg6xJ/ImNSwqCTZ4j03qbmIstIz0f6ZLmc4KQ3v361t98uj6t8Ar
         Wwd56xvN86mgZyf8FLquZ0KNVduYmaobocqe6rvQ9yr3Sdf4Ia2HkWvHFzClAgMs7cmR
         0QqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=WQe8M43LEf3D6dp9Ny7bhpUVRfoW7k8zR+S9BDyhw7s=;
        b=Z5sDj96DBRcuiPmYDAIdNaSt7ITCrb8C+LAKa9XTu+xujplLaFq5G0w7jtl4Khmfrb
         NUdYo+GDpaWTwSvt+YejRcLBvddAHqolA1g22oSdcQI3ZeqVMJr6I9geHMMoX7SgKPbI
         zTRf9eHXnb9A7VPsG1fJfWQUsYMll5IzzCwPoyMsZiyaoC0ftGnG8oQUXU6v8abz0eE/
         Q6zEJVHSt8ViEXEzroBGiaXOBgOsm2dFfvQMbhS5sXpo01qsr31gsONqWhOGb0wf1lId
         310J8U1mnfeqMq2Zk/kvbHN6rM44pP0yS6kMBV8Bv0AGNVDh3go+EKmpkBE5npi5Emp8
         nhTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z75si117111wmc.151.2019.04.16.11.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 11:35:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos.glx-home)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hGSvi-0001D1-V8; Tue, 16 Apr 2019 20:35:39 +0200
Date: Tue, 16 Apr 2019 20:35:38 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Nishad Kamdar <nishadkamdar@gmail.com>
cc: Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, 
    Oleg Nesterov <oleg@redhat.com>, Will Deacon <will.deacon@arm.com>, 
    "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, 
    Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>, 
    Peter Zijlstra <peterz@infradead.org>, 
    Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
    Joe Perches <joe@perches.com>, 
    =?ISO-8859-15?Q?Uwe_Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>, 
    linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: [PATCH v3 2/5] nds32: Use the correct style for SPDX License
 Identifier
In-Reply-To: <f6a7c31f4e8b743a2877875ac3fc49ecb8b9eb0c.1555427419.git.nishadkamdar@gmail.com>
Message-ID: <alpine.DEB.2.21.1904162034260.1780@nanos.tec.linutronix.de>
References: <cover.1555427418.git.nishadkamdar@gmail.com> <f6a7c31f4e8b743a2877875ac3fc49ecb8b9eb0c.1555427419.git.nishadkamdar@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Apr 2019, Nishad Kamdar wrote:

> This patch corrects the SPDX License Identifier style
> in the nds32 Hardware Architecture related files.
> 
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Nishad Kamdar <nishadkamdar@gmail.com>

Actually instead of doing that we should fix the documentation. The
requirement came from older binutils because they barfed on // style
comments in ASM files. That's history as we upped the minimal binutil
requirement.

Thanks,

	tglx


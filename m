Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E606DC43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:01:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C1BC2190C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:01:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ip5AZ7/z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C1BC2190C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDC9A8E0002; Sun, 17 Feb 2019 03:01:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8D508E0001; Sun, 17 Feb 2019 03:01:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B55178E0002; Sun, 17 Feb 2019 03:01:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 749C68E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 03:01:52 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a6so2919866pgj.4
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 00:01:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Vs43ryopCuySwq3NVh5Rkay+eaFs8osV1LCjn4b3Yk8=;
        b=W7P9RH4JDaArVZmRWSuawRd+1WvP+HoqhKbt+a8BUoftBVsgoYj8c0q/b7KjRTXi9x
         JdAuWJyhUoACEuZzrOxJPMJRIlz4CFStm/WX2xwZbyoPuKWFjmYUNZ5sEF6RUF90U3mv
         d7wDxjlP0G80jEWnMwYLUT3aq9unLdwfqqUcsJgplL1ttsAU0I1Gg0FCUB1bAj8PNKdE
         XdyTuJFRVzZlzzWad70ZsOEPuZNIkUvIMHpGx/BxQyCQDgJFu7gmk+aE8W4VoNh0GmQ7
         6YSp/wfLvOTHPhIoBuyIdkGsLf3nQDHtZ3O8UkkSUqTSbAkmhGwqGK4gnyXv1chOPq4H
         ozUA==
X-Gm-Message-State: AHQUAubICw2wtRfKGxS0ljXH82c9KdCcQN15gmgvh5HeHvDyBfDgQR5i
	tA4jIuxW0eQLg5A25swm/i77baNkT+dx+Kl8M+RqA/YeBct5xPKl4IawphGit7+A96ObmC5JQt0
	8WCN2jIjrAlb4Z7egeQYs1SAfJXa/KFD8ymBesqMoK0b3Q29Jlq3dII8dKfR7DCb4zvPJ+0cfmQ
	xxhckT1ybMT9mcgzi854PqRoHy0k1xbLcfuazfQ/SOGfSSrY6g7HjB4uZ9bDpU6C2fJelYjAJHm
	mulAYXO9hfkoeAjWogB4mIn3jcAxNR4sZLmcGW6qW0Bb+kusNJ8ZxOkbf95lulKdIdSp8euHwhc
	I2t7Q+G6YHnVRsm7viI+WAH0Yybedh7Fj6E8QaTS2xqOtVMEaZ/5fJS1/WcrrVl7CfslFy2faPF
	d
X-Received: by 2002:a17:902:834b:: with SMTP id z11mr19507526pln.151.1550390511924;
        Sun, 17 Feb 2019 00:01:51 -0800 (PST)
X-Received: by 2002:a17:902:834b:: with SMTP id z11mr19507459pln.151.1550390510931;
        Sun, 17 Feb 2019 00:01:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550390510; cv=none;
        d=google.com; s=arc-20160816;
        b=g6YJu8BZ1JCYEXgozka4r70GzHO+HMRXmdXWrgZTd5wWXSDCp4DLr8DhKTDJTHqRxG
         gNTgYe8CSkFpsC573Zp0rvIjBl1pXLuPSl6SsdX8qDA0C3V240RWUJx0lT/26KX+mjC5
         b6W+XTU9jIysbPHjjDVXiPrO8mTMGDZRb8dSxlqBahjzl9OP0x80zGhAxr1L8L2HJT/c
         hVQpqcszv1Rmuh6fOBNTfdr3BhbInvG64W5aSyz22ghF2hA8Gp378EMKFHjeAr7ZM+RX
         6dM5+3cUa+xgX2ugzROP5hKCX00asIlfhGlRZgSmDqpEKnpTfsAXMJUlnE26rvawte9y
         uSzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Vs43ryopCuySwq3NVh5Rkay+eaFs8osV1LCjn4b3Yk8=;
        b=ZxoXUDP168rEiR78VX1s8ZGn2hap42Zg0dgtWRjkb1dht0ncflPIz6ML/Jzu/xfFie
         0dfO2kHrFB8Rr5rQuM3EhBGCmD4CoV9HJU++dIETeGH7x30yv3+LcgtKtf0VnvREpsmp
         F27v1J35lVp+YEqNir6nhs9Ke7taAn3lE7eZCOm/Rul59tKyk5zomp42xGEkbBgfSVmb
         8l4BNJGQU+nwx3Y3EbQ5WVQMsX5Rgr5BJoxFnZP2qeD56Tkb2+sAOobdqdsoKX3MaGCN
         +cR+gMSPKqBA+uXEusjl3KjNl6EX08LLmZTiLDiO+yyjt+2l66dOa5x8zJsGhtELBq94
         kkZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ip5AZ7/z";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3sor13112940pgp.41.2019.02.17.00.01.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Feb 2019 00:01:50 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ip5AZ7/z";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Vs43ryopCuySwq3NVh5Rkay+eaFs8osV1LCjn4b3Yk8=;
        b=ip5AZ7/zgFdLotaIBOzYnrE9abvw/324UL1EYwNpqLz3W9ywxAWGtu94Xz7gevL5tA
         2SeWBLuJY922ZG4EZf7lppox9ZyvXFAH7Gh4glmc60G2TXPVD96SYYgVbpl/MX/4LbP7
         wyEcMVKqobp+Ktu1qFnDfboBKDHQovwtyQlTvKF4hWE1AptrkhqLHfe6ubMdV7NcewE1
         FQraD/eQutZWDDEGyjRER2g11WV1HJ3J4s23NVpj9EPCOjU6yM4ZIEMX23RpUEpFNg32
         m+ug1E9vS7Axgq3mzLQN4GFi2Ueaptr9SoKuSKXcNzzRIqK8oZlMtBv5PnVZydiJ/kxS
         r1oA==
X-Google-Smtp-Source: AHgI3IYGAE8sPzJwy30E8Ka1QH6i8Ua2hpoyXuGZF2tOQR09bsSMbpeTZME0R4mNjXcRe42WkJmuHg==
X-Received: by 2002:a63:134f:: with SMTP id 15mr13121383pgt.19.1550390510020;
        Sun, 17 Feb 2019 00:01:50 -0800 (PST)
Received: from localhost (220-245-128-230.tpgi.com.au. [220.245.128.230])
        by smtp.gmail.com with ESMTPSA id c4sm10657429pgq.85.2019.02.17.00.01.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 00:01:49 -0800 (PST)
Date: Sun, 17 Feb 2019 19:01:46 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, lsf-pc@lists.linux-foundation.org,
	linux-mm@kvack.org
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
Message-ID: <20190217080146.GF31125@350D>
References: <20190207072421.GA9120@rapoport-lnx>
 <20190216121950.GB31125@350D>
 <1550334616.3131.10.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550334616.3131.10.camel@HansenPartnership.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 16, 2019 at 08:30:16AM -0800, James Bottomley wrote:
> On Sat, 2019-02-16 at 23:19 +1100, Balbir Singh wrote:
> > On Thu, Feb 07, 2019 at 09:24:22AM +0200, Mike Rapoport wrote:
> > > (Joint proposal with James Bottomley)
> > > 
> > > Address space isolation has been used to protect the kernel from
> > > the userspace and userspace programs from each other since the
> > > invention of the virtual memory.
> > > 
> > > Assuming that kernel bugs and therefore vulnerabilities are
> > > inevitable it might be worth isolating parts of the kernel to
> > > minimize damage that these vulnerabilities can cause.
> > > 
> > 
> > Is Address Space limited to user space and kernel space, where does
> > the hypervisor fit into the picture?
> 
> It doesn't really.  The work is driven by the Nabla HAP measure
> 
> https://blog.hansenpartnership.com/measuring-the-horizontal-attack-profile-of-nabla-containers/
> 
> Although the results are spectacular (building a container that's
> measurably more secure than a hypervisor based system), they come at
> the price of emulating a lot of the kernel and thus damaging the
> precise resource control advantage containers have.  The idea then is
> to render parts of the kernel syscall interface safe enough that they
> have a security profile equivalent to the emulated one and can thus be
> called directly instead of being emulated, hoping to restore most of
> the container resource management properties.
> 
> In theory, I suppose it would buy you protection from things like the
> kata containers host breach:
> 
> https://nabla-containers.github.io/2018/11/28/fs/
> 

Thanks, so it's largely to prevent escaping the container namespace.
Since the topic thread was generic, I thought I'd ask

> 
> > > There is already ongoing work in a similar direction, like XPFO [1]
> > > and temporary mappings proposed for the kernel text poking [2].
> > > 
> > > We have several vague ideas how we can take this even further and
> > > make different parts of kernel run in different address spaces:
> > > * Remove most of the kernel mappings from the syscall entry and add
> > > a
> > >   trampoline when the syscall processing needs to call the "core
> > >   kernel".
> > > * Make the parts of the kernel that execute in a namespace use
> > > their
> > >   own mappings for the namespace private data
> > 
> > Is the key reason for removing mappings -- to remove the processor
> > from speculating data/text from those mappings? SMAP/SMEP provides
> > a level of isolation from access and execution
> 
> Not really, it's to reduce the exploitability of the code path and
> limit the exposure of data which can be compromised when you're
> exploited.
> 

Yep, understood

> > For namespaces, does allocating the right memory protection key
> > work? At some point we'll need to recycle the keys
> 
> I don't think anyone mentioned memory keys and namespaces ... I take it
> you're thinking of SEV/MKTME?  The idea being to shield one container's

I was wondering why keys are not sufficient? I know no one mentioned it,
but something I thought I'd bring it up.

> execution from another using memory encryption?  We've speculated it's
> possible but the actual mechanism we were looking at is tagging pages
> to namespaces (essentially using the mount namspace and tags on the
> page cache) so the kernel would refuse to map a page into the wrong
> namespace.  This approach doesn't seem to be as promising as the
> separated address space one because the security properties are harder
> to measure.
> 

Thanks for clarifying the scope

Balbir

> James
> 
> 
> > It'll be an interesting discussion and I'd love to attend if invited
> > 
> > Balbir Singh.
> > 
> 


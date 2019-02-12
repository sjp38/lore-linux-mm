Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C41BC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:36:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D9C420855
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:36:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="ij6cI5fI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D9C420855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF7018E0005; Tue, 12 Feb 2019 11:36:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA6E38E0001; Tue, 12 Feb 2019 11:36:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBEFA8E0005; Tue, 12 Feb 2019 11:36:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C35B8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:36:37 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id v67so16042252qkl.22
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:36:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=98BSrrPqdO2vLypKZPM3TMscNVA1xtajyssG0F2CG4A=;
        b=lgLLnKQ+kR+TKB2C+E2XsbJfekajvpMLXeBCzrnueRDkwqNS+AuSsswJgoUFWuPMfq
         c/VgwpirCWILXngRvl1U62vW/VkZHvRGwurHLIdHwjSaIPuMKhXCmCpFajL661D+98+a
         pHE30uL0p4w7CsZ0LFBG/dtkNmxz+P5CsOxejAzBrsNmGg4kioRU8a4njf8bWZJkpH/J
         6vFypH7sjdnEbj06qo+GB6Q/QfthedyRvu7xh5JtFlHUF7miGCb6tQLHV18Z7VJytEN5
         Ij4vSt7EvY4y2lC974oExj4dwMhhbiUoMIYqM6ZGZNO46v05xFdOlDz5bvnNlEj7G71+
         KUuQ==
X-Gm-Message-State: AHQUAuY/MDPhQKScK17jEEZ1eR6jvtBXmVM/EcxKR0AUflA903IYwBtZ
	UIsvnPF68HIcDfl7gmOrt05biGn4IeGahTVOhpe9IAshYYZIsyDY7AQn+bS1G2wNiMcACCS/Fyc
	Stu7DGV5fI9mXMi3ibOb4cf0DN53JyHqNOPJxS3cYs6Y0Kxqvlgqg6IiLbv83k7M=
X-Received: by 2002:a0c:ae1a:: with SMTP id y26mr3360228qvc.234.1549989397402;
        Tue, 12 Feb 2019 08:36:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaOZwZ29M4JyBRPN8EEWIlIgdTHvUi79n+4MLxhPX3mL6Kj3/Jy1xbkx/yEwV7zqJJ2wyTQ
X-Received: by 2002:a0c:ae1a:: with SMTP id y26mr3360197qvc.234.1549989396945;
        Tue, 12 Feb 2019 08:36:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549989396; cv=none;
        d=google.com; s=arc-20160816;
        b=M8xeshWXHmPBj12UHcFsOEjpAn6xsFDneykzAlELOWCVETbtj8ffoaraDx80DR4DZa
         xXiMEuohle0cdDNUzCDb+mXpLZYV4FmZvGOEPg3RfCjgzbuQd9EwTEEVPci/Xzg79Avu
         lGy9CCP0Np+ljtu0qGN8bRlVgHiil4uItmpjDMYXZRzdX3u/Y2KAXsx4praK6ufHb2/1
         1zmRnvq4F+qOBH5nKYSqLpio2UZ8YHh+lFjiqkXpu6CuJp19y7SCqMeYHAfteJtLkNQS
         sLya3zOSQj3C4ILvYOyDeCHgZYr1EeCbmeMsMuFoLEvMBLx+AReFmSbVzjsVx9er9AR/
         KPIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=98BSrrPqdO2vLypKZPM3TMscNVA1xtajyssG0F2CG4A=;
        b=GSue/3QzyHWq6cfAnpcoxCUvEl9dsVRRqdgng2XhPcKGC++AG4wUyENbG+k2IMP2SI
         7/Eq4Ga7cBpwXZNoawlmaE/dQYwBmUEGyCRKSj5AnKRjX4Rx0UDxZhSKaP2N/qX8V+FV
         e9BCYxc1AaAjQIehfYjEH6xGx5QK4tLKHyM4lGl6f9Oiydu/IYEki+Y0hFlL9sLKNWEN
         nJJv2RNJp/qbpwS1acPqmUsI90oe5NLaaGsfxcDiKS8WNyBwv3l9oAJ6ivb2a7ocTWTI
         C3hX7hKhNL3czdGrwIetjQTekr7JJ7Dp+F1GNionMYMOQqdOscw/vROgjwSlK35Sn6Vc
         Qnmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=ij6cI5fI;
       spf=pass (google.com: domain of 01000168e2913f2e-56010847-a10b-407e-b4eb-7730164267de-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000168e2913f2e-56010847-a10b-407e-b4eb-7730164267de-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id w4si2734260qtw.380.2019.02.12.08.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Feb 2019 08:36:36 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168e2913f2e-56010847-a10b-407e-b4eb-7730164267de-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=ij6cI5fI;
       spf=pass (google.com: domain of 01000168e2913f2e-56010847-a10b-407e-b4eb-7730164267de-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=01000168e2913f2e-56010847-a10b-407e-b4eb-7730164267de-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549989396;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=98BSrrPqdO2vLypKZPM3TMscNVA1xtajyssG0F2CG4A=;
	b=ij6cI5fIk1W9Uqxy4H/82RA/mSETWX5OjNOJ6+Fe1YaAP8sfIOf7a4Kx6reL6Jae
	Uz3CSh53BZI3D7nIFYvBFyUyK3A909rmd8oA+f3lMBCIjbdEn/jXPbE/3cr1PAtj++y
	BtFdzXKLU04EjRLWjSCEUtCrAo/sa65SJir7bjMc=
Date: Tue, 12 Feb 2019 16:36:36 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Dan Williams <dan.j.williams@intel.com>
cc: Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, 
    Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, 
    Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>, 
    lsf-pc@lists.linux-foundation.org, linux-rdma <linux-rdma@vger.kernel.org>, 
    Linux MM <linux-mm@kvack.org>, 
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, 
    Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <CAPcyv4jHjeJxmHMyrbRhg9oeaLK5WbZm-qu1HywjY7bF2DwiDg@mail.gmail.com>
Message-ID: <01000168e2913f2e-56010847-a10b-407e-b4eb-7730164267de-000000@email.amazonses.com>
References: <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz> <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com> <20190211102402.GF19029@quack2.suse.cz> <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca> <20190211181921.GA5526@iweiny-DESK2.sc.intel.com> <20190211182649.GD24692@ziepe.ca> <20190211184040.GF12668@bombadil.infradead.org> <CAPcyv4j71WZiXWjMPtDJidAqQiBcHUbcX=+aw11eEQ5C6sA8hQ@mail.gmail.com> <20190211204945.GF24692@ziepe.ca>
 <CAPcyv4jHjeJxmHMyrbRhg9oeaLK5WbZm-qu1HywjY7bF2DwiDg@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.12-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019, Dan Williams wrote:

> An mmap write after a fault due to a hole punch is free to trigger
> SIGBUS if the subsequent page allocation fails. So no, I don't see
> them as the same unless you're allowing for the holder of the MR to
> receive a re-fault failure.

Order 0 page allocation failures are generally not possible in that path.
System will reclaim and OOM before that happens.


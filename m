Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 874D6C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:25:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 449DF222BB
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:25:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="HXnNE81t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 449DF222BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D32C08E0002; Tue, 12 Feb 2019 13:25:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBB508E0001; Tue, 12 Feb 2019 13:25:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAC248E0002; Tue, 12 Feb 2019 13:25:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA578E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:25:51 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id i18so3553982qtm.21
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:25:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:user-agent:mime-version:feedback-id;
        bh=DA2gSutaqsxnfso2DDmkhMQLi+JnpXSKlZxfKSvZHTY=;
        b=ELDk3h/0mBXV1kq48+r112qaVNOaqFw/4EC7J8t/aVPEqp1w5AK4uL7DQEtVxM2dSW
         LT7K5KVoxfVau6XJx4sr4TfshFyBx66suJXO1Uj2p+DbIKXQEwEazJt80OL98yyDh0zX
         vk5f2w670FBm1YBdADeVrF/mDnKpWin02ADeYMGDgPmYhVwqOJsjo3/3ZOWeTKp6xHtY
         CHdn/NU9r/qnTClcOzGlYCCGXzHeMc6L4ohKbYeqUukqqYb+4Xe6fNm28dk7Gc/fCIMP
         xM8XAuae2f/sN1ou24GJI1JiVRTJUMzB8kBt/beYV37iS3rnoa3lSmOue6KFx9bepjdA
         FXCg==
X-Gm-Message-State: AHQUAubyV9SxEBDcB1+Drr3N87Up5DKEClNSjOqCoUWL/Oy9W23cE9/E
	L6c2YORvTIQgIw7COe1VeylathrvJ+/PvZsPacNscAvypOyN742EMGRUEWRYDIJCyc0rFlS3scz
	QXoo/N84rsBd7ZUlZFNlSc6lG8tdc+DlO9wXgh4K43FJ7+PKeyl7HchHdwmQKUn4=
X-Received: by 2002:ac8:3209:: with SMTP id x9mr2110291qta.315.1549995951288;
        Tue, 12 Feb 2019 10:25:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYN5In9M76ZC3Nj6+1sLMSk0zeCFq2jgOs601E9/BXwMVhAQIczescPw42LrRtku2gDNyfb
X-Received: by 2002:ac8:3209:: with SMTP id x9mr2110262qta.315.1549995950745;
        Tue, 12 Feb 2019 10:25:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549995950; cv=none;
        d=google.com; s=arc-20160816;
        b=VfpE/i3IGfNCybyN7BbSIAYGScNq4bWtz1Yap4i0FdWDJpoFhBVRGz7igDWDjKzrXU
         ZRsn9+QacHtHEPjkBTjGfgOzjhk7+yf+2IQFOhKxzzb++AaLRlurvzzkdIwgxduaj6r/
         6hfvPa9bSLR1jKKbB/eGkvuIZBmV7qYlbdKaBambkg01dy1Y0BGAWG8MpIE5FlbRAuU0
         LaHQroi3SJeilUY5ZZ96MFA/MmiycA2Hn0XYZ7M1z0I5EyaSkBh6hEKT5tWmg3dKC9p/
         RE948EChiUL0uvczTpbTZPARPr5VOmEtFzkkpyvY4YJ8yvBESbhgKdkfr0EK7AGcywx9
         K8MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=DA2gSutaqsxnfso2DDmkhMQLi+JnpXSKlZxfKSvZHTY=;
        b=og5n9J6hguXoF834kjsznu4ENNOaPl2xKqCuaZ5SAMGIRbHdEeKz2Fk4ukuBuMS+Z2
         Yx4WXHSppNoJi/otwhnZYcyZS078XeyuG4LY4wLcC3E+oSTjMQ0F0yXXsmS8uXQCz1ms
         KRybvMiUqcw5G/OxCyCvU1dRyN08FJB5o/Vcz/eJc2MZG+8rQC7x5PGTA3XV5kl+NVO0
         k2psfxatZ6EcYZ9RCweaUIrZ/kBGm4hWSP2LBnX6N7KSifn2OUBqNWc4oFxAXseXPNrB
         +z46t/iY2MaGuL87pkTUDo47ZEDGJia3JEnBr4AIwTmzuxxBGjuf7dDUvfPJLkuykaR6
         Wv7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=HXnNE81t;
       spf=pass (google.com: domain of 01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@amazonses.com
Received: from a9-32.smtp-out.amazonses.com (a9-32.smtp-out.amazonses.com. [54.240.9.32])
        by mx.google.com with ESMTPS id b5si2861383qtg.383.2019.02.12.10.25.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Feb 2019 10:25:50 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@amazonses.com designates 54.240.9.32 as permitted sender) client-ip=54.240.9.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=HXnNE81t;
       spf=pass (google.com: domain of 01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549995950;
	h=Date:From:To:cc:Subject:Message-ID:MIME-Version:Content-Type:Feedback-ID;
	bh=DA2gSutaqsxnfso2DDmkhMQLi+JnpXSKlZxfKSvZHTY=;
	b=HXnNE81tIyNidWyt42M84oxppYO/oE/brXa6txo+UmmXt35V09rvwcDb7mMHGCF6
	OovhFtjgFjYOC/QCQMdlPpiztizG+tutWLXHb8lZiFdFKH8QY0VrtCenqCaYPKvx+FE
	vKFSbUm58Gn/Eqz610w3fgEULiLREhGkPjFA2xDQ=
Date: Tue, 12 Feb 2019 18:25:50 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: lsf-pc@lists.linux-foundation.org
cc: linux-mm@kvack.org
Subject: Memory management facing a 400Gpbs network link
Message-ID: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.12-54.240.9.32
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

400G Infiniband will become available this year. This means that the data
ingest speeds can be higher than the bandwidth of the processor
interacting with its own memory.

For example a single hardware thread is limited to 20Gbyte/sec whereas the
network interface provides 50Gbytes/sec. These rates can only be obtained
currently with pinned memory.

How can we evolve the memory management subsystem to operate at higher
speeds with more the comforts of paging and system calls that we are used
to?

It is likely that these speeds with increase further and since the lead
processor vendor seems to be caught in a management induced corporate
suicide attempt we will not likely see any process on the processors from
there. The straightforward solution would be to use the high speed tech
for fabrics for the internal busses (doh!). Alternate processors are
likely to show up in 2019 and 2020 but those will take a long time to
mature.

So what does the future hold and how do we scale up our HPC systems given
these problems?







Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 928E5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 16:34:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A84E206B6
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 16:34:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A84E206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8300A8E0002; Fri, 15 Feb 2019 11:34:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EA1A8E0001; Fri, 15 Feb 2019 11:34:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CE4B8E0002; Fri, 15 Feb 2019 11:34:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED718E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 11:34:23 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id e31so9290508qtb.22
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 08:34:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=i+16PszETtw2S9m+snfkdJUfUT29WQ6yt+wb/R96IrI=;
        b=dBu0JlBP2V7jei7bk7ZRLJB+7xc+AoXsEGGFP3u+vMK5R09P2grOOJPuDiPgYtHH1t
         n+Jfvz254HUPgI3j2HiHwUJuG11VMIhFeDDBV3NqlTkRQLWk5x3lZprDwiG7bq/IZQDD
         bh3kWo/gPCKHfRdEr73nyuRJti6FaWStpMkf/+eYGj9sFXBz01D0beFGcSAl9nI0bEja
         YSA3Q815ed6hPM009+n4jGejqmY+6EXu2qUNT/ZLN9wMJAVCqRyLkD+yDEmTbdY1UacF
         hEgYOg4GVtcZlsmgHg5CtOUZ6k9RpGwQ4dsDjhwme1LKre9vdvh5HrwNUsJ3JVp2c2xK
         x8og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubsRcdXgj9UZ3W2XOrca8zQBnB6C80jvAGY0j9DTzBBJRuFjOup
	yd8Dv2qO1OWVeJUqpdMoGIM52H7F5pHFRIdFYWPyLtWcVnlw1FtxVtEwhaKberY9ZOEt71gb7Pu
	kT7b55uD+A41k1RpDodqhltRdN1hqTPP6+xUFXNFexk5ffnXan8QEvKfMklswPL9LGQ==
X-Received: by 2002:ac8:2798:: with SMTP id w24mr8161773qtw.280.1550248462926;
        Fri, 15 Feb 2019 08:34:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ+3EG6oYDT/J5jUVMnvztZx4a4VqQZAQ3/Fl4yTR1O4Qw4XTVgHFvz+VTn0Mh1KPLdva4E
X-Received: by 2002:ac8:2798:: with SMTP id w24mr8161734qtw.280.1550248462339;
        Fri, 15 Feb 2019 08:34:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550248462; cv=none;
        d=google.com; s=arc-20160816;
        b=jfUjcBBZGWI3cgwmwB/q7kJQA4CcZfQudl9VXrgx4rjRN7+QlKQ1BaYsMG8PyUa3qu
         iuRp92xzA1rwX4MxCN5DI49vo6egXMOdIqfYbz1fqruFFJPO1S0T0fByDo1zwr7b0Z1G
         SQbEk3iUau+TwOwxXCuq9Ixrlpd/Bv2X9+B1uxMPTdQ6U6565i2vhGixnv3QGxcu1koR
         hl6K/JKWEm5MTAIQyhfRGI6yDKsFmqSL/EgUMDE5DRU5BsjIOk3LOJ/Rij7kOSgLaOxg
         jR1xZeVq5blUExcpIfK2Lu5uwY6rgrHttfwpKwIsTQEgGnbic4HlUHjtFtVHvnufpYFb
         impA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=i+16PszETtw2S9m+snfkdJUfUT29WQ6yt+wb/R96IrI=;
        b=MA04IOfOgxNyQ/0N/VncSnZFKFg1G9fDPDg3uQp3KnUc6ZeDPDND0PKwISwIrY5MNp
         n61AlVB2EBSSNJPfImmpag4aRWVY71Y2nyIpI0XovuNVY/gIeswrkYhYfHqnPozmbhwm
         /qznA2QCcdcBqAGNPBJDYwGIaU7B4C4u5UA0gQOUqfjU+CTRBJvUqWurfRpBU62DRA9C
         rbeO+btaclf/Th9B5mNsvFG4rvDTIdR4nUSkIQtTYXqZL/KZAaHPVF38YCVN/7CQKHrF
         BZzQqOy+KN/7DUmg5IHRCBDbmvA8ZAP1iGrUXuQvIk/wQoIAG6yVSz6riPtFwp2DeG4g
         DmSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r43si2561430qtk.21.2019.02.15.08.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 08:34:22 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 78D36C0ADB4D;
	Fri, 15 Feb 2019 16:34:21 +0000 (UTC)
Received: from redhat.com (ovpn-124-3.rdu2.redhat.com [10.10.124.3])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A55B460933;
	Fri, 15 Feb 2019 16:34:20 +0000 (UTC)
Date: Fri, 15 Feb 2019 11:34:18 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Christopher Lameter <cl@linux.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: Memory management facing a 400Gpbs network link
Message-ID: <20190215163418.GA4262@redhat.com>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 15 Feb 2019 16:34:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 06:25:50PM +0000, Christopher Lameter wrote:
> 400G Infiniband will become available this year. This means that the data
> ingest speeds can be higher than the bandwidth of the processor
> interacting with its own memory.
> 
> For example a single hardware thread is limited to 20Gbyte/sec whereas the
> network interface provides 50Gbytes/sec. These rates can only be obtained
> currently with pinned memory.
> 
> How can we evolve the memory management subsystem to operate at higher
> speeds with more the comforts of paging and system calls that we are used
> to?

Couple questions. This is not saturating PCIe ie we are talking 400Gbps so
~40GBytes/s right ? PCIE 4 is ~32GBytes/s with x16 so is this some kind of
weird hardware that have 2 PCIE bridge and can be on 2 different root PCIE
complex ? I heard this idea floating around to get more bandwidth without
having to wait for PCIE 5 ...

Regarding memory management what will be the target memory ? Page cache or
private anonymous ? Or a mix of both ?


More to the point, my feeling is that we want something like page cache for
dma (and for page in page cache we would like to be able to also keep track
of device reference). So when they are no memory pressure we can try to use
as much memory not only for page cache but also for dma cache/pool. This
might mean that we will need to rebalance the page cache and dma cache/pool
depending on knob set by admin.

Obviously when you run out of memory, pressure will degrade the performance.


> 
> It is likely that these speeds with increase further and since the lead
> processor vendor seems to be caught in a management induced corporate
> suicide attempt we will not likely see any process on the processors from
> there. The straightforward solution would be to use the high speed tech
> for fabrics for the internal busses (doh!). Alternate processors are
> likely to show up in 2019 and 2020 but those will take a long time to
> mature.
> 
> So what does the future hold and how do we scale up our HPC systems given
> these problems?

I think peer to peer will also be a big part here, for instance RDMA to/from
GPU memory, which completely bypass the main memory. Some HPC people talks
about even having GPU and CPU run almost unrelated workload and thus trying
to isolate them from one another.

Cheers,
Jérôme


Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28F98C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 11:32:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBA0020652
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 11:32:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBA0020652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 754B98E0011; Fri, 11 Jan 2019 06:32:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DE948E0001; Fri, 11 Jan 2019 06:32:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A7C18E0011; Fri, 11 Jan 2019 06:32:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F10E8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 06:32:57 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w4so5980669otj.2
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 03:32:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=9WuW2iWvYf8AhFWrUoQ0lTlxA9Uj+Ul6pIlgpeQBrdc=;
        b=iq6FCO5hQ8fhD/pJNNsusfSQlcRadzfow2UFVs6AyKm3frfN06gyUzR3SlR2rVs8pZ
         AOlF6k+iNnBLsaqK6/GUs24g2WAiHsKBI7LlTfM8QvIiE3H20ezZARGNTSg0hxpEfYQc
         9wBqfztAWkuDAO3ExCyLANMrIr6CS1cAYkKg8sXsFK9T7A5aEg64zhyNnq0QpQ7PX0T6
         VIrQJNgvClmdRlelbfx9cMH86Of6VUdyha4QeBBWwurPeuvjR02rq9ZcKwfcwQUuJ/YY
         fe9jg2DhLaK3IpSP0IHhN0RmLgLUxT+Sbsjbf29fzRCfDDjfVf0P4mdVf6xHUKnKhvqz
         BwSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AJcUukft4cC2AxY55ChNzODxrFjLPm9YIze/1xu1yKnomKThqperVPi1
	6YkxI7vqzhaUjobl8TgEZK6sbVLGUOowJChuxTRMd0lfQn+Z4jEN1Gf9S3qnwhmKYih5DsSQ2l4
	0SiLRTGAIbPdzLWEgHajEcUj98ya4JN800heXjvIn87Y+Tv7QTvWDgkmGjRN42bnpDg==
X-Received: by 2002:aca:6995:: with SMTP id e143mr8429942oic.283.1547206376801;
        Fri, 11 Jan 2019 03:32:56 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6GkxP6QXLGUpQ7mW96g8zks7SmncELdF+LGy7puSjNKdyLmoBUd5RRM3I4UuKRUi5em2Cm
X-Received: by 2002:aca:6995:: with SMTP id e143mr8429914oic.283.1547206376098;
        Fri, 11 Jan 2019 03:32:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547206376; cv=none;
        d=google.com; s=arc-20160816;
        b=dnKpGjncLI7OKuFq/mbNNyylEYKAjfHIK+na11v5eSOF1pyPBvjl2uvhg7QiSeGOn6
         huNRAQ+GfUzRdvbbkX5I5WxtOeEvbWbumxJQcCt1IsnidHbhZA38Z3zBt1DWzY+uli+H
         kIo5aqKFar4SVr3Ey+8o0dYhHv4hMW1jjNOgtE2yQRUox7Nh+vWoo3+QkVVni2Fz5vBI
         jIYLIICx/y1gGlaXSGu8AeabyRhBuaHM0aq0W3a6CQpCSpoHp6cTPIxl+JagajI4A8xe
         wE65ZyrvdLelRPKgwpZxdjbzewOb6wx4bsnWcwTgfd73jhi2np11Nb4C1oxyAC2ab28Z
         nN6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=9WuW2iWvYf8AhFWrUoQ0lTlxA9Uj+Ul6pIlgpeQBrdc=;
        b=0+UYPsHdLEZ7sj0yxZC9Uh+1NwjEs1f2bdBkHAL4+/Sx+O4dXPqpgTbokpYo2T0Gcw
         RDwABpFg0GyVWRJ+vrh/sPynqltVKTtYHPxX8Df3WJN7k6Wyo09yMYEeAzYxQPpPOK+1
         uB3afzXD0YjlvFH798XeWYZyGM/LToTHqmHfB+u5FykoKDBCkISfoRkn33iBazxmNAc2
         g8DpAGliR59B+fuvXC/dlEcAqoN78ZCLjyZoiUGcL7P8D9hhcLTLwPNao3tW6tv+5vgO
         VP/51UpuuKjIdugJwvLbXYKM5x/XyfY1/v786LaNHX/4Dkd3TuWi0utot6t++phvwwqO
         zLmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id x72si26366566oix.204.2019.01.11.03.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 03:32:56 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id B0DB6391A3618A6E0D1D;
	Fri, 11 Jan 2019 19:32:51 +0800 (CST)
Received: from localhost (10.202.226.46) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.408.0; Fri, 11 Jan 2019
 19:32:48 +0800
Date: Fri, 11 Jan 2019 11:32:38 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>,
	<linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCHv3 07/13] node: Add heterogenous memory access attributes
Message-ID: <20190111113238.000068b0@huawei.com>
In-Reply-To: <20190110173016.GC21095@localhost.localdomain>
References: <20190109174341.19818-1-keith.busch@intel.com>
	<20190109174341.19818-8-keith.busch@intel.com>
	<87y37sit8x.fsf@linux.ibm.com>
	<20190110173016.GC21095@localhost.localdomain>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.46]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111113238.Pn15710ZvsRxyk_RZGKoOeHEQaG5Y4fNFN1u1pJISSM@z>

On Thu, 10 Jan 2019 10:30:17 -0700
Keith Busch <keith.busch@intel.com> wrote:

> On Thu, Jan 10, 2019 at 06:07:02PM +0530, Aneesh Kumar K.V wrote:
> > Keith Busch <keith.busch@intel.com> writes:
> >   
> > > Heterogeneous memory systems provide memory nodes with different latency
> > > and bandwidth performance attributes. Provide a new kernel interface for
> > > subsystems to register the attributes under the memory target node's
> > > initiator access class. If the system provides this information, applications
> > > may query these attributes when deciding which node to request memory.
> > >
> > > The following example shows the new sysfs hierarchy for a node exporting
> > > performance attributes:
> > >
> > >   # tree -P "read*|write*" /sys/devices/system/node/nodeY/classZ/
> > >   /sys/devices/system/node/nodeY/classZ/
> > >   |-- read_bandwidth
> > >   |-- read_latency
> > >   |-- write_bandwidth
> > >   `-- write_latency
> > >
> > > The bandwidth is exported as MB/s and latency is reported in nanoseconds.
> > > Memory accesses from an initiator node that is not one of the memory's
> > > class "Z" initiator nodes may encounter different performance than
> > > reported here. When a subsystem makes use of this interface, initiators
> > > of a lower class number, "Z", have better performance relative to higher
> > > class numbers. When provided, class 0 is the highest performing access
> > > class.  
> > 
> > How does the definition of performance relate to bandwidth and latency here?. The
> > initiator in this class has the least latency and high bandwidth? Can there
> > be a scenario where both are not best for the same node? ie, for a
> > target Node Y, initiator Node A gives the highest bandwidth but initiator
> > Node B gets the least latency. How such a config can be represented? Or is
> > that not possible?  
> 
> I am not aware of a real platform that has an initiator-target pair with
> better latency but worse bandwidth than any different initiator paired to
> the same target. If such a thing exists and a subsystem wants to report
> that, you can register any arbitrary number of groups or classes and
> rank them according to how you want them presented.
> 

It's certainly possible if you are trading off against pin count by going
out of the soc on a serial bus for some large SCM pool and also have a local
SCM pool on a ddr 'like' bus or just ddr on fairly small number of channels
(because some one didn't put memory on all of them).
We will see this fairly soon in production parts.

So need an 'ordering' choice for this circumstance that is predictable.

Jonathan


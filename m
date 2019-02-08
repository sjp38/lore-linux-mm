Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 185BEC4151A
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:19:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD5A720863
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:19:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="ZY9qesP9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD5A720863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 205CB8E0077; Fri,  8 Feb 2019 00:19:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18CC38E0002; Fri,  8 Feb 2019 00:19:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 005F08E0077; Fri,  8 Feb 2019 00:19:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD7CC8E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 00:19:54 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w20so1623527ply.16
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 21:19:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BYbBSsXD8XXPJr8WmxtwPC6HBpOHhpTEB9wAZo2Q1Iw=;
        b=UY3cakSj3uvRFhH3u5aD4ZN6I/t0KTQZ/ppE/z06TqD0kKeAaSktP4ZAEb6fM/VX18
         8HxIBE5gF0cpJIGliQGaydn9UuTac6jJUp7Yrp8gqanMvdc9yYNiJ5gMK+3q8xN8SC1Y
         rfpCeond4gnqQqgbxfKKzDn2942wkgF0V6cBNWYBZ2Y5fH3XUYNDNy+gcpbdYxrVaR6L
         Nu0RUmXc6qLke4dtCplaYBK/JenlKIrmVkC0SZPac2w32xfDR7jm2UnMrx7tOAWDjcSp
         F260PsSnJc8cjQZKuK0r4k7BJEpdr5RZ8VGjsW/RaZl9TRu8m8/LiEtgZA3Yvvo4zhIE
         7oaA==
X-Gm-Message-State: AHQUAuagc9lINjA8oOQlvS2YYIOoHhDUPkY4QuHvNLcZz4yWstm8NTuB
	3GUtvApRhNK8IJc8NXEV5tQk/Il3c2bCbX5QBVLqX+k/IbkJpF0+AorquqAHY16iJfQsCrCSGPl
	Xktc/oj631SpZV1o5B9Z9KmqTTro1qMDaUX6KJ0ySXweX4qgvcreOXdZalu5WunhppgeipUAlfe
	UVqcK1eyWT2hUQQzbjF76G3bPHWTZ7yUEYsh+kQbH02i8atF/2g0jN+Vyik9PtAUz+qryXBc+v8
	OI/ve0lPkPlhwFyAu1DJ9Mk08BpAaV+ZToA2MVggBNQkZAvBjqnBkuMqL3OZ/9pd/jMJi4M3ZOG
	CSfOZAzzPFvXr+o1Y1iNH5NUz+oWdtUoASAsX9DLHBI5ZaMF4uJ1djVzvvunhZhzJHQdU7cmx8D
	9
X-Received: by 2002:a63:5e43:: with SMTP id s64mr18711567pgb.101.1549603194269;
        Thu, 07 Feb 2019 21:19:54 -0800 (PST)
X-Received: by 2002:a63:5e43:: with SMTP id s64mr18711518pgb.101.1549603193431;
        Thu, 07 Feb 2019 21:19:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549603193; cv=none;
        d=google.com; s=arc-20160816;
        b=rxqoIhpKG+/Q8j4NVpWKroVs9JLH0vnhK2QvT6sRe4fhmQP1Fmh1HP9qJzeOHmGBb5
         A/746g8wLiKltz4y3gcf37dtOq2HmvlZmuMFEoz255np+Ow0s0T/Eul415Oi1EUL1ll2
         WCbKn41Ga6UJcBBx5/sVehgq4VLFa2qZxByWYFGQpwCBkXiWF5lejP8bP0HoF6GARyEY
         B8LMAvHM5iUTF6qGz9WucJY/Y1pT2tnf4QIUVUfsCPAZjrL7oLgyIu8mBrTFHRV8LjpW
         Ly9aJBDbL3BHD+ISYFq9U1+WrdMSoUvWyL7KRyjpo4AcfiTd5K8ylSNPWtQwbk1qRF4A
         XgjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BYbBSsXD8XXPJr8WmxtwPC6HBpOHhpTEB9wAZo2Q1Iw=;
        b=mWarV/djIbK4CXtzNL71LmFk5CxkXKYC9ixtpds+ySIwKWK2S7LPrONJkmLo8xyfGT
         ZLXKyiSbhSc2fIi+LeaYxG+FLuZKYlgJ0CavJKzF1i7nXxc3/CYNEYxazoNnjFnQGYoh
         gRILT8U0sGeZKcQX1vBh8TD6zEnRAPyB62pkwYXaUoq6iEpKilLpmDT1upiRsMb2FxAh
         wMSZFS8LKBPxEhGiz6mFch3/En7iWNoHyo1yJom+gMj8vhC621veQNHWdBnhK+Gelx0I
         XXvukASXa1VobiqrgLmS+LdwJBtrVOTOvpG2GVpi/oPzuGYtT2HLe3fmHLqnZnxQWOFm
         k+5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ZY9qesP9;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc12sor1418499plb.37.2019.02.07.21.19.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 21:19:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ZY9qesP9;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BYbBSsXD8XXPJr8WmxtwPC6HBpOHhpTEB9wAZo2Q1Iw=;
        b=ZY9qesP9VVn0x9e71+u4lkQ//uBh7kJgGvlvQKRWeoCf4hvZtlJxqBWlgNIsBozfuw
         PdiI4WYxwxhuhA+2Sgprj5UL9o5hea0yoh9+Ctc3FowkhG51kFr8aedwRShg+QKcaDCW
         tIY0lbhw0VWFe5rVm0M2wXVtSouGOAhLUfZ50+m3NGMVTTrnEeKRxLxi0BdKLdR7nIiA
         XEYfw1JdCfICZ/gylNCtg2bIU+Rm1+9QUR+dnNgdoU5lcQEY8JXoxLEdbOeFNsjs58Ms
         yjBkj2TK4LWgLjeiJEPhzVoyPpQRQIMnqvxzPKyKJF6lFGUzbvvWjTcEHrDFrmsmTVdQ
         Iftw==
X-Google-Smtp-Source: AHgI3Ib+Q8mmAigiLi1jjcsVDeZ6rNsQaeyBAKdrDXlYrjxQElJhijsWAqyqebNTeTb+oDehCRzanA==
X-Received: by 2002:a17:902:298a:: with SMTP id h10mr20875446plb.312.1549603192845;
        Thu, 07 Feb 2019 21:19:52 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id d16sm901999pgj.21.2019.02.07.21.19.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 21:19:51 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gryZq-0002AV-R9; Thu, 07 Feb 2019 22:19:50 -0700
Date: Thu, 7 Feb 2019 22:19:50 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190208051950.GA4283@ziepe.ca>
References: <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard>
 <20190207052310.GA22726@ziepe.ca>
 <CAPcyv4jd4gxvt3faYYRbv5gkc6NGOKjY_Z-P0Ph=ss=gWZw7sA@mail.gmail.com>
 <20190207171736.GD22726@ziepe.ca>
 <CAPcyv4hsHeCGjcJNEmMg_6FYEsQ_8Z=bvx+WmO1v_LmoXbJrxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hsHeCGjcJNEmMg_6FYEsQ_8Z=bvx+WmO1v_LmoXbJrxA@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 03:54:58PM -0800, Dan Williams wrote:

> > The only production worthy way is to have the FS be a partner in
> > making this work without requiring revoke, so the critical RDMA
> > traffic can operate safely.
> 
> ...belies a path forward. Just swap out "FS be a partner" with "system
> administrator be a partner". In other words, If the RDMA stack can't
> tolerate an MR being disabled then the administrator needs to actively
> disable the paths that would trigger it. Turn off reflink, don't
> truncate, avoid any future FS feature that might generate unwanted
> lease breaks. 

This is what I suggested already, except with explicit kernel aid, not
left as some gordian riddle for the administrator to unravel.

You already said it is too hard for expert FS developers to maintain a
mode switch, it seems like a really big stretch to think application
and systems architects will have any hope to do better.

It makes much more sense for the admin to flip some kind of bit and
the FS guarentees the safety that you are asking the admin to create.

> We would need to make sure that lease notifications include the
> information to identify the lease breaker to debug escapes that
> might happen, but it is a solution that can be qualified to not
> lease break. 

I think building a complicated lease framework and then telling
everyone in user space to design around it so it never gets used would
be very hard to explain and justify.

Never mind the security implications if some seemingly harmless future
filesystem change causes unexpected lease revokes across something
like a tenant boundary.

> In any event, this lets end users pick their filesystem
> (modulo RDMA incompatible features), provides an enumeration of
> lease break sources in the kernel, and opens up FS-DAX to a wider
> array of RDMA adapters. In general this is what Linux has
> historically done, give end users technology freedom.

I think this is not the Linux model. The kernel should not allow
unpriv user space to do an operation that could be unsafe.

I continue to think this is is the best idea that has come up - but
only if the filesystem is involved and expressly tells the kernel
layers that this combination of DAX & filesystem is safe.

Jason


Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55229C04AAA
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:44:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ADC32075E
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:44:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="TAjDKfRe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ADC32075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A30C46B0003; Thu,  2 May 2019 14:44:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B9846B000A; Thu,  2 May 2019 14:44:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 881CF6B000C; Thu,  2 May 2019 14:44:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 619236B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 14:44:45 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id i125so4833826ywf.5
        for <linux-mm@kvack.org>; Thu, 02 May 2019 11:44:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0H6/1V6/5CIKh3CDtEYPw4qJMt0j8mXo9dQuEOmaJ2c=;
        b=JIb/dLs6Ww1EMG+6It3QjJz0BDtMwnq3EnxbVZp8XJbndsUuC3AXJ9Mnfr79T0CqHO
         0OUBKgO1lzhiFcedhkhyCBd38735x6IZpBPOGzxonbJj6D2xmFmP9cEPZF3llrdTAE+u
         I0sJjVK/ZCAoZBnYCEX8FY6OVGc37zvKu1cCOeX7rEKlFNCiQs+QdbP3SfasNjVO6G2Y
         fu9TNirCXl7SzHCZvTMdr60zokeKbjN5N/47LhhJL778ixvhM1Nj59IwW7lrKMOAbiBK
         FCUFvaXjy42s9gOXtkyTx2KpgHVXxmf5IM4ZxFzztAsTMlsNwZksTk5NIDUROyhgHbVA
         HXQA==
X-Gm-Message-State: APjAAAV7WPE2Ac/6LdrkTtbEcpqxjnk/QVJfByJ+KakLvr6N1baHGQoZ
	8ZUE1r+JVwePURAqGUcEAJL/W0SY0YsjpeJck81c/Rq1LzB5dgmq9gVacHtoQwvRaTeb0Uj9M2Q
	IktdoKIvrQqdqmw1qfVLopZgLAvKNpUYMiS4nrKzQSK7JOeHhTY9nQKTd7lcQW9Xfag==
X-Received: by 2002:a25:c281:: with SMTP id s123mr4516157ybf.401.1556822685157;
        Thu, 02 May 2019 11:44:45 -0700 (PDT)
X-Received: by 2002:a25:c281:: with SMTP id s123mr4516097ybf.401.1556822684039;
        Thu, 02 May 2019 11:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556822684; cv=none;
        d=google.com; s=arc-20160816;
        b=BuUqBg0TfOEzeWddkBbE/Tl82H38BjE4gO6Hcgryb0RQFHxogZjRud7udZ0aF5X5th
         HrGJBYolFf05veJyID4MDr2iWKwrpkfmUHacnV3zlA7bdQt6Wbe0/74FVSU6TZ3D2Qn8
         7pEAlpeVP6XbOJzDM8XQJ0CFye0k2ClEFYAveiYArDiA7GFSWD/O1OeQA8pZGz6V2j8Y
         Wj04a610YavVw0s1jHG74YjF/u2eb8dvfj06lt/H7kdia1do8AMGoVNIvPQtLYe066G/
         c2Qmez/NaMuzY19GUk/yqYaij2ixd3QIqo2w80Q34PoDj0/W1yJY5nzU7So2GNY4ksMW
         LvtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0H6/1V6/5CIKh3CDtEYPw4qJMt0j8mXo9dQuEOmaJ2c=;
        b=gBVlvFbp+8FkcGUYMmI/HB5lX91u3fKWDtidjS+xNbmLTgq7bZ5RkA+2bIIy2f59oy
         WWStRDEnhATzD7CyGs64ouG85TQ0zpEisaOTcYiG3y/3gRupO/zY0JqChC7PXb69uxkF
         zP0q4KrkzJSiVRABfrx8Izrptxgoj3GFqtzUBxMJqW2wQC16IJIl+aED4OvVpTV95yhz
         lUvAV1nHI6NXTSyICNr2gSgZt17R7ASgwHwLfnvnHoQ7LQ29QdlBGlY1xXSyqyh/L1mF
         aMG+I0b/fPno6i6eodGyg+XMyWXmSS2IZlyPRWnbUv67Euzq+tMPQycM7chZCGNj1cxB
         dUQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=TAjDKfRe;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w62sor2456271yba.86.2019.05.02.11.44.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 11:44:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=TAjDKfRe;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0H6/1V6/5CIKh3CDtEYPw4qJMt0j8mXo9dQuEOmaJ2c=;
        b=TAjDKfRewk/UKamdlBYp4Z/f6fr9mzmhTBqPKn6Tso2lr/AkBQ1LMwAK9XIDmPfqWH
         1X2g+ZiCkYEJEIfn+6n2PJc1Ev9G5K81J+GgEo5MfNluS5utNruV2aiJWOsWhO1L39V3
         Z6C+J9uqiqXPYgQ6dcQSGANxw+xbHRVZAHWyN5hgFksgs/XhUgIKGl/0h+zrDIy2eofo
         aoMe+6WRmr7JILlqWxy3H4DaUeYvmUJdygIwom0nYWR8nN82LMnNt4srD1UZaJjPLcot
         OJpUgaV5+1lK6hPsIBFneSFAOj6A3kBGy7IE9y3T5wB9bI5Hesqt1uBVI3nJujocribj
         yDpA==
X-Google-Smtp-Source: APXvYqym/T/mBRrGXQQDSpwxLouliK+q+GpIj38u16aTEyLNBYQwSdaMmlgY9yKwhmdV2+JjJHDJNw==
X-Received: by 2002:a25:5d0f:: with SMTP id r15mr4433647ybb.373.1556822683578;
        Thu, 02 May 2019 11:44:43 -0700 (PDT)
Received: from ziepe.ca (adsl-173-228-226-134.prtc.net. [173.228.226.134])
        by smtp.gmail.com with ESMTPSA id q204sm16965820ywq.44.2019.05.02.11.44.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 May 2019 11:44:42 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hMGhG-00026A-3l; Thu, 02 May 2019 15:44:42 -0300
Date: Thu, 2 May 2019 15:44:42 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Leon Romanovsky <leon@kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yishai Hadas <yishaih@mellanox.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 16/20] IB/mlx4, arm64: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190502184442.GA31165@ziepe.ca>
References: <cover.1553093420.git.andreyknvl@google.com>
 <1e2824fd77e8eeb351c6c6246f384d0d89fd2d58.1553093421.git.andreyknvl@google.com>
 <20190429180915.GZ6705@mtr-leonro.mtl.com>
 <20190430111625.GD29799@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190430111625.GD29799@arrakis.emea.arm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:16:25PM +0100, Catalin Marinas wrote:
> > Interesting, the followup question is why mlx4 is only one driver in IB which
> > needs such code in umem_mr. I'll take a look on it.
> 
> I don't know. Just using the light heuristics of find_vma() shows some
> other places. For example, ib_umem_odp_get() gets the umem->address via
> ib_umem_start(). This was previously set in ib_umem_get() as called from
> mlx4_get_umem_mr(). Should the above patch have just untagged "start" on
> entry?

I have a feeling that there needs to be something for this in the odp
code..

Presumably mmu notifiers and what not also use untagged pointers? Most
likely then the umem should also be storing untagged pointers.

This probably becomes problematic because we do want the tag in cases
talking about the base VA of the MR..

Jason


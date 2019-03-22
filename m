Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DA1FC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:52:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 372462192B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:52:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="e1GXrN0y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 372462192B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF9C16B0005; Fri, 22 Mar 2019 13:52:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D82B86B0006; Fri, 22 Mar 2019 13:52:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C70DF6B0007; Fri, 22 Mar 2019 13:52:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 985776B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:52:27 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id i3so3059369qtc.7
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:52:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=4LmkY378p9IKWuPaxRNrOpznTZtEYeypgpUdKx9r6Vo=;
        b=Sb3zklo1qGB19VIZZqf0p44sx3hFnw1vJsILVm+rDMTNU4JDSSr4jACV/qJsS0b/Sm
         EBCgkjwzlfVr1HEdylX0dfMTRNITLsQgGXz4aT4JMgxnjkfohoT36cY9wJuiW8jU597D
         uNDa0N64C9SpfYAYYzii4tAOw0hC+0gDoyU9cbT9wWrebmCi5wBD+Ewscyj1UNDaxHRO
         J8FoCaVtdPjl5L6gBObzxUG/+fTAzYFXKnrnHWqEz+DOy5HXN/AzGo7zuKr1Apw8HJpC
         WhHoQj/kybaT96EfJFgG9ebNXzdMJF4WAM2Nur8q372vm0yuFqZ9kaMbA7qcvzAIBEbH
         QVVA==
X-Gm-Message-State: APjAAAWrWIm8HPXVreuCAZSAX15I2ToB3kcTLp0+N4iQjOgQLj7CG0nM
	nqI1aVVriLldgElbMr44Rxx4VROP3DCjMu3eHPho4YdtymqmlLnsf81TVh8+clj0MYAOZ8Ypv/B
	2ShqS9x3Aih1o/JbGb9gC+CGGzQJLOOjvWbQDGMfDs72oSlcHUzfhIT9WDHsYVIA=
X-Received: by 2002:aed:3904:: with SMTP id l4mr9052561qte.194.1553277147402;
        Fri, 22 Mar 2019 10:52:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyel0m1j+ELoeofeP8Ode/9LYTNHC2FIa1YZsiG/ZHYg4CpI6SIUVFYo1WymmgO+DXZ3Mj6
X-Received: by 2002:aed:3904:: with SMTP id l4mr9052496qte.194.1553277146374;
        Fri, 22 Mar 2019 10:52:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553277146; cv=none;
        d=google.com; s=arc-20160816;
        b=F59OX14A0vhVzxCBdN17aIKddeIUImiKkezlZIn0KfSynZSRVbxAWu6AXQZ/9PGIO6
         xU1GTw4xT+eXwAvGovtQh9WUfTwV9qDWF15ZT1LnyDSJcXkFld2PBGIyB85bWmZ6c0Vh
         q1LcZgDg5yZiHYyY3z+aeYRFq6LmY6vcDai+I55kHHf5plYFVPnYRYE+h2eZfemq72YX
         3GfyCYZ80s1aRsF9XQa4Z0O+jl9B87IGviFrIbSEYib1NIWIUyhbb0C6YAhvi0wg4AkC
         Remmpf25BpB2Vd9i5GLMuMTmGUbxcGhiItuf0ZZyIAsctn6dB9Jyxr8/+nX7JaTAHcIL
         zfug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=4LmkY378p9IKWuPaxRNrOpznTZtEYeypgpUdKx9r6Vo=;
        b=LVmekKtxHaF6aROTj264t5GKwF3ONtojCNki/qGTFULF/l/C+2sLOx2XdOfIJSNs3Z
         klz3kv9thnFhL5MfrXRGgVam4yO5Kkj10PQbHBLq19PJ8q/Hkqas4J7A+7SDX/hbExUb
         Ob2+agNL2Fkpl+DNDpYR/ecTKaYosoSO6+YZNfpDrQ08itVlEdGBMA08Vc89vlT3/g6+
         kYxfsK1c7KSXOCdczqtoT7DP/Etf0oZvWcrCIdJMq5oAUJNm9/GMxO3YqrC6xtxKAoht
         6eh45I2D1m5WzaUZBRGsZEvjD03D1Q7vjpJ98pSCKLdk8ZA+ZW0AwwwLj1RSgGwT4LIQ
         UX+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=e1GXrN0y;
       spf=pass (google.com: domain of 01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@amazonses.com
Received: from a9-32.smtp-out.amazonses.com (a9-32.smtp-out.amazonses.com. [54.240.9.32])
        by mx.google.com with ESMTPS id e3si546308qtp.104.2019.03.22.10.52.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Mar 2019 10:52:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@amazonses.com designates 54.240.9.32 as permitted sender) client-ip=54.240.9.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=e1GXrN0y;
       spf=pass (google.com: domain of 01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553277146;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=4LmkY378p9IKWuPaxRNrOpznTZtEYeypgpUdKx9r6Vo=;
	b=e1GXrN0yDwa0T8TV5m5Wqs4aJ+t7LB51Oh3a8UvZRW7aYkbfdw131t5ua28iVA5J
	9PUjeLS565oBrK4sUjVng25TgdtBqwPK7fvvCaxeyAY7d/YXa7Be2flDAGwkW5BUnQ0
	lJzae1gKtLzFhDrcOOVDXC7sYlEwIvEwszRDzY24=
Date: Fri, 22 Mar 2019 17:52:25 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Vlastimil Babka <vbabka@suse.cz>
cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>, 
    Matthew Wilcox <willy@infradead.org>, 
    "Darrick J . Wong" <darrick.wong@oracle.com>, 
    Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@kernel.org>, 
    linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, 
    linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
In-Reply-To: <4d2a55dc-b29f-1309-0a8e-83b057e186e6@suse.cz>
Message-ID: <01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@email.amazonses.com>
References: <20190319211108.15495-1-vbabka@suse.cz> <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com> <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz> <010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@email.amazonses.com>
 <4d2a55dc-b29f-1309-0a8e-83b057e186e6@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.22-54.240.9.32
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Mar 2019, Vlastimil Babka wrote:

> That however doesn't work well for the xfs/IO case where block sizes are
> not known in advance:
>
> https://lore.kernel.org/linux-fsdevel/20190225040904.5557-1-ming.lei@redhat.com/T/#ec3a292c358d05a6b29cc4a9ce3ae6b2faf31a23f

I thought we agreed to use custom slab caches for that?


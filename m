Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CE24C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:39:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFC9920855
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:39:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="L9qVsApf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFC9920855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A0898E0002; Tue, 12 Feb 2019 11:39:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 825AB8E0001; Tue, 12 Feb 2019 11:39:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EE698E0002; Tue, 12 Feb 2019 11:39:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5E88E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:39:44 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k1so3314707qta.2
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:39:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=QONQxq6NqJ1WQyN3EWBcAnyyjiKu2fZbxNpfP8BUfQw=;
        b=a/kpIo2Tl3vVk530kVReTIsToBawKcmEmNpENOJ2ZBDcSjfdHqcUVPviMt5rAZZzd0
         eoEvcOtyduvT8x7oV1ft+Ngs3iP9Ui5B0q82BHzvFn4NUeUHN+GKOCtBAEKHSlOCIbkv
         xe9Ng/d04hdBXchJx18LKv3wl1QU72taa9T2/TXxtq8qcGv4wLHF1RzX8s0VrySnpwGH
         f/ommkAdq/q84MHGlbwqxYAHGYy7bWlpkzYh685l6YeM/1pOX8MvQ1TClreAYNiu2sNV
         RYoENFG4M4bxhNQ3HpU4BQjlLRaTeRoS4NU03e/FwAFl+w/VPYolpr4sQalyyPPw9qsu
         KH8Q==
X-Gm-Message-State: AHQUAuZYGAhIjgQ3FT/uUAiTsCpW+zAMWEONJdxhcax03m71p7dWWtQR
	fppc2rjnWXT9NSW0BQM43eNRGme2qEdAwg6H2nC/AqI3VGqF4H8f2IO+wmMEMomnESKl9N2CLeX
	IGefw3tX372itM5ckjg8NLdBx8ewF54pkgQmREOughDJ2PiBgyBGdsXVQsinStc4=
X-Received: by 2002:aed:2a18:: with SMTP id c24mr3267683qtd.99.1549989583941;
        Tue, 12 Feb 2019 08:39:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbHPhZWkdtwmTiTIm00gJkpGCwnXY71hkvY2lmkOXKAYdJt54i572mOQ9FJp5uwp5AOKcgZ
X-Received: by 2002:aed:2a18:: with SMTP id c24mr3267653qtd.99.1549989583456;
        Tue, 12 Feb 2019 08:39:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549989583; cv=none;
        d=google.com; s=arc-20160816;
        b=PfYOkRR1Ra83weTZLm0hyuuLTV8FdQi1sQ471NKVKrkXnV6RSjJprzCMXsqBOX6ut0
         SdrL330suKQW9tg1D1nHEyVxzGaylRGbPJ2fAFz/2QuynuNjcl5PMElk6AoVrxs67INw
         WCc8tJqNl6ycGt1SetdP3ISe2Bbiav8ovTy9YmOkW/rYi4ymkTc9AIVykKNmxQLf8KDx
         xDZZvLWHGKQPFEyW/31nxmT6SrwUOWVUk3So5/WKzvz6c9uHS2dqwscJRalt9EgN/j3q
         Yv+tJH1jZVbEo4r6DWWeOGszy81rbVNQC4nQr+S13SmtSMPBi6JHbDLPjNrdbXN2FPi9
         UgeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=QONQxq6NqJ1WQyN3EWBcAnyyjiKu2fZbxNpfP8BUfQw=;
        b=u6wHLTuMU2W3WlNX1RL+joFKV1k6icDPci5ra3Rrc/H2YdE9hentD2QXWdhIztoy1D
         hGm9A2qrPV6mdU8WyvqdRgQ7OmtHtN4T2h0WbSk0Fi6zXIYCRtlwsdKUz3Z+zhp9ZKKk
         MqYDAT4ouWbpxIq4xkPXCgIWG0MhqYOYeWbmEfH5yPRWkmslmN5Mr1kw3dFcVVPgPhm5
         PhV6CBDn4wk9li0HDMo/Ca2wNO+AmNw1515B/z6bGkvSQyoWt6+PQ7g4nL8air/5iuiz
         GLhpaLukdwk7T3nObSaoC4+ouriOgQMVDL+uMOw0MCPZkyh4h29vqAPUdrzwcTQv/lko
         0YPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=L9qVsApf;
       spf=pass (google.com: domain of 01000168e29418ba-81301f56-9370-4555-b70c-3ad51be84543-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=01000168e29418ba-81301f56-9370-4555-b70c-3ad51be84543-000000@amazonses.com
Received: from a9-31.smtp-out.amazonses.com (a9-31.smtp-out.amazonses.com. [54.240.9.31])
        by mx.google.com with ESMTPS id v9si3517926qtf.314.2019.02.12.08.39.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Feb 2019 08:39:43 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168e29418ba-81301f56-9370-4555-b70c-3ad51be84543-000000@amazonses.com designates 54.240.9.31 as permitted sender) client-ip=54.240.9.31;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=L9qVsApf;
       spf=pass (google.com: domain of 01000168e29418ba-81301f56-9370-4555-b70c-3ad51be84543-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=01000168e29418ba-81301f56-9370-4555-b70c-3ad51be84543-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549989583;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=QONQxq6NqJ1WQyN3EWBcAnyyjiKu2fZbxNpfP8BUfQw=;
	b=L9qVsApfysCu2oX2ycOKEAIsoSsfsL401tm3A5JhTNcfPRycrN/SU3q03Yg8CacL
	iUWr90rd4XwT+bw/1d13ahfJRucia0Sc1lYrTbPfbF243/9D/sIIqLWAb7mYBFB4+aK
	Iz4Mws7VxD3GCLqKnJO1/FdcgEhND4r84guKpcFE=
Date: Tue, 12 Feb 2019 16:39:43 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: John Hubbard <jhubbard@nvidia.com>
cc: Jason Gunthorpe <jgg@ziepe.ca>, Ira Weiny <ira.weiny@intel.com>, 
    Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, 
    Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>, 
    Matthew Wilcox <willy@infradead.org>, lsf-pc@lists.linux-foundation.org, 
    linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <018c1a05-5fd8-886a-573b-42649949bba8@nvidia.com>
Message-ID: <01000168e29418ba-81301f56-9370-4555-b70c-3ad51be84543-000000@email.amazonses.com>
References: <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com> <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com> <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com> <20190211102402.GF19029@quack2.suse.cz> <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com> <20190211180654.GB24692@ziepe.ca> <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <fb507b56-7f8f-cf2c-285c-bae3b2d72c4f@nvidia.com> <20190211221247.GI24692@ziepe.ca> <018c1a05-5fd8-886a-573b-42649949bba8@nvidia.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.12-54.240.9.31
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019, John Hubbard wrote:

> But anyway, Jan's proposal a bit earlier today [1] is finally sinking into
> my head--if we actually go that way, and prevent the caller from setting up
> a problematic gup pin in the first place, then that may make this point sort
> of moot.

Ok well can be document how we think it would work somewhere? Long term
mapping a page cache page could a problem and we need to explain that
somewhere.

> > ie indicate to the FS that is should not attempt to remap physical
> > memory addresses backing this VMA. If the FS can't do that it must
> > fail.
> >
>
> Yes. Duration is probably less important than the fact that the page
> is specially treated.

Yup.


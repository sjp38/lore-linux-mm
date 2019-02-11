Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DB14C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:06:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBCC5218AE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:06:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="E+H12NWq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBCC5218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E0688E011E; Mon, 11 Feb 2019 13:06:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 790408E0115; Mon, 11 Feb 2019 13:06:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 680978E011E; Mon, 11 Feb 2019 13:06:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC808E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:06:58 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id r9so10390479pfb.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:06:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=w0y9hW+FfwZmqRbEGDUn/tatRO/LwdPvsfhlv3Glf8s=;
        b=YChqDPVhzOl9Z1qEVYi+k473rLnkBb6RXZF/ZygYwOvbebLfy+8+kJeTuJSpY1R/7X
         UhjlrvJdfNS43ottaA7EzKPphgM/Qh5qG0YYuZBqH60fKZlo3mC+GbO+lAytknPOUE1/
         mk0HyZo85QGRXGBtSh2xsPNsHJa51cVabGFdrB/v+el9xPjQ1HtXIKSdZ3Lb4zfMjxQJ
         ryK/FHnjT65DyxHRoebfVh9e+kvdNuOnWRXL5lC/FJN3//uB5XaV7yO2bUv5azsMGJrH
         yChU4Kfjv58eobcKHoEM8Dc5v655UthJu0yK0mn4mPzCy+3pAVCaNy1cXN645dyzc/qu
         O0zQ==
X-Gm-Message-State: AHQUAubcJSBjt3WLf7iNTxvpnBtciT5uAxWGVFpeLQW8gX3C2EF/OEeH
	q4qfNm1SS0bdw7+XSJvn/i+0Fqbe45HkQUac79lYSgvkOQmS/nd1iSlg3hYGsCvkr+3VZFSMPG/
	H5gI/tdlu7sHBX4L5cKz7lKEL2TUzfYMUvTaplmcvRMRMgQIh2RC+3C2TTv5Lkeh3dPZodnkJIu
	XnZnQckp7zJzBVj/7VKENGKXZeDW9lIbFmmLiwAm6UtvBcfcztz3N5/diXUTl4ia2Wpv/o8QnWq
	ArA24fpAXycfXY3KxfEqmxYD/Jgez7SyX5rs/FVgmUftDWYtmTMAR3YDOWfFWzWOg3oJBQE9Ptg
	nyDqQ9r62D6oFEx4fVljAkdtc7H+9rTqfztw4oDGP0jawBpLmcrOYlVPExv5sZvwE31mPEUoGez
	h
X-Received: by 2002:a17:902:a513:: with SMTP id s19mr9121346plq.324.1549908417868;
        Mon, 11 Feb 2019 10:06:57 -0800 (PST)
X-Received: by 2002:a17:902:a513:: with SMTP id s19mr9121295plq.324.1549908417122;
        Mon, 11 Feb 2019 10:06:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549908417; cv=none;
        d=google.com; s=arc-20160816;
        b=dpRQmEIxyH48iyFtVlMclELY8MhY1AHFRjbcu4haIuPEaxQWLUmswbiG01OcR0XeqE
         ymNCbBdTBq3JK9NMt/yaD6PNEddlDiasI9QL0jsi2rI2iS3dk2mRwtYoalfb5uNSFOcU
         GnHPkp3Phad6MV6jDCDxS89CI5j4eKN8DkqCXdbhZZ/OvdZhvq97ezS8MmK/Tcf4Wz2K
         jFu5DmBZqKF/61p8UXNXlCSt4xBWJDFkO3vAIi3hQoe7hRfjLJ7hm9a8UYuNyCzEJRbl
         IxLGa/RvCZDKeDnSHsnpVlH13LhgrV2t1x4rYRRaBsbZdW9EfBeMwK/CLPq4257gVfef
         dG6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=w0y9hW+FfwZmqRbEGDUn/tatRO/LwdPvsfhlv3Glf8s=;
        b=XZjIw1ahaRO4KyZar11/nHJZKSJlWya+1tfkCWSkCMNAZ8qZk5RCO9Njt6u92+rOK+
         sguKSf0Wa89RSre1NQNj6OrU31p5WmI+IqqyNFiKw4Js0lVkNyOSmvLbG299Vp/WXQp7
         ZXqQt+yB1Ja0O87uBdx+3N51BEzOxXE6kpDXE080fEKogtJ1H1CImwU/pLDP1NDveRop
         rBAUvV3syl2zjP7F/i+r/S4n/DT36ANg0DEw2TYhon7JMNrlPI02hHry7BlBCufWKH5k
         O1ilqO1/3+k2XkGURsP/IoSyfh5itQhpqpaOm8LlAI9y11O3+tfZypwBw5cM01D4ceml
         kpXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=E+H12NWq;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2sor4894441pga.55.2019.02.11.10.06.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 10:06:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=E+H12NWq;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=w0y9hW+FfwZmqRbEGDUn/tatRO/LwdPvsfhlv3Glf8s=;
        b=E+H12NWqOH1kocgLBJFfdyfUTGtO82CGQL/Q5abd40O4IhGdaqRBFiSCmc8bOl2JEq
         wxji4EQNCE0kjaQDY58Pr8AW0elv7SDRpJjmnPhtSKWmRdld9oOKPYdMp8cbXgtihTkN
         YpvY7172JPcd5+1Lr9i4nZ3vf7k3qSYDtPP45P0RbHthJysr6EMBaIa1vOnqFzQmAGIw
         lV90ylsROmy8J6nqSihqEou9kzzxl1X/Rl52pKQxPd+e6XJUuM371VUuxLXRcZDDJ5Zr
         9Bb2FEcJHJDnRVloNx7ntigxbFa0dg5+evw5ZRVt3HY4E02wLO1DDSnQhyTTuACCjnJG
         brwA==
X-Google-Smtp-Source: AHgI3IYFKbr0OJw7ra16rDwj01hO/nL0Ie5rDJ3B2Da4ACI0vdwlOV8s6fKzhRtr2bq49AsRzuru/w==
X-Received: by 2002:a63:d70e:: with SMTP id d14mr34732488pgg.159.1549908416674;
        Mon, 11 Feb 2019 10:06:56 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id a187sm9735052pfb.61.2019.02.11.10.06.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 10:06:55 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtFyo-0007co-W4; Mon, 11 Feb 2019 11:06:55 -0700
Date: Mon, 11 Feb 2019 11:06:54 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190211180654.GB24692@ziepe.ca>
References: <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 09:22:58AM -0800, Dan Williams wrote:

> I honestly don't like the idea that random subsystems can pin down
> file blocks as a side effect of gup on the result of mmap. Recall that
> it's not just RDMA that wants this guarantee. It seems safer to have
> the file be in an explicit block-allocation-immutable-mode so that the
> fallocate man page can describe this error case. Otherwise how would
> you describe the scenarios under which FALLOC_FL_PUNCH_HOLE fails?

I rather liked CL's version of this - ftruncate/etc is simply racing
with a parallel pwrite - and it doesn't fail.

But it also doesnt' trucate/create a hole. Another thread wrote to it
right away and the 'hole' was essentially instantly reallocated. This
is an inherent, pre-existing, race in the ftrucate/etc APIs.

Jason


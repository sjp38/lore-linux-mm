Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D9CBC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:19:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04B0E20869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:19:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="bqv/NYzz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04B0E20869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 971668E0004; Tue, 29 Jan 2019 18:19:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 920A48E0001; Tue, 29 Jan 2019 18:19:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80F348E0004; Tue, 29 Jan 2019 18:19:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BB908E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:19:07 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s22so14932709pgv.8
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:19:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yVMgdFOdFa/I4N9PyKEfemOmqSGsE9eLQyaSPEIZUh4=;
        b=JO7lPxbxWiQ4S1V7b4if3mI6/ecbvYyqiPZ/kxNA3lxgiJmxoi8vZleF0WnzLUyojY
         xrtIwJdRfwJ76clxBl9TmzbvYNLW7PQ2Ink3Z2mLGfESVexYsHuXxAzzqjVwB68PymQZ
         9kJewRrbRzPvl+qilsBuTNVx3OLuhrJZFqcbWvstLDaLsj7kYlifuv3Vjl2/4hTTEJBf
         tNUkOwqjWde1NvdVbM3pka78gWg2dDVoNq507TOAptglv9xhYUhby3+StxuZAuQG7J3Z
         8YkBzYU2MtAPNTRbtZFlhr8x1MlEKsg7z9GxXNrADtv6VWDx4UTNPQbhFE9E2f9f9LXa
         Gcxg==
X-Gm-Message-State: AJcUukeW4EWSQScxdh9SW1k792u/APKXUlxIOqpIDGH69NMHyP//kOFb
	ISUu8Iwe4ksiqkINX/VozsCYnXc8HpbcWjbeKIELb09+5zF4JLtYtYy7BFg0fdg07VcBjR4HTvz
	4xBjHWmcNgJxRZgxQSTtt1ZNspt4MIfuX1yj782mukN0ET/cgNYfM+YWwpVMG4Ypfmv8s1R9ELb
	6UFzIMqeJI6LhTPduRfdxYlqNqUVkvbGW25x/QzUu6c/+JzcLgOEL6MxX05vSFpixEIGbkwoRyo
	PrvPnP9dLz87e02K5a7sei+8u08HjbUOoccfMHNVO8nlDYyuAdkHQBbjXFyHOO21HSpNVND2lUF
	N281CtibVIII0Rt5MczGwAqifv8Q923TlijU8gm7DGuPWJmWzhdDFmPLr01m0HIxTUg8aeyLfpE
	2
X-Received: by 2002:a62:5444:: with SMTP id i65mr29086462pfb.193.1548803946888;
        Tue, 29 Jan 2019 15:19:06 -0800 (PST)
X-Received: by 2002:a62:5444:: with SMTP id i65mr29086417pfb.193.1548803946154;
        Tue, 29 Jan 2019 15:19:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548803946; cv=none;
        d=google.com; s=arc-20160816;
        b=Kmzbz0qe/qtYyhtkHy5sMX5lqtVdarUkfOr7nVD3nJgsy35qinngM0fWIjpkppnRVH
         R6iwlY2HP0fAxuNLkXVbTuQeF/kWKGoHOEafUDwvV1qmS2XDw2+B7oapwmli/G9VkmaU
         vZPG+eFK0QKC8nZT+JwFOylel7wvLrti9oHs5gJ+7ouu7egL7aheMwmlJkkJQY7jZMwA
         nV5wXh7UpklG3vygioE5jfZjf94eEQY4LDK61O/lqgujfDkfxzogWlgkL1t0UVsKuqB3
         3ak6sjji7m/FdA9T+CDpc5I8zOSZR2mRV6obgPJg4k23JqAYYCHlVnQ5XWtXACIRKfp3
         ZG3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yVMgdFOdFa/I4N9PyKEfemOmqSGsE9eLQyaSPEIZUh4=;
        b=S8hw/W7n+ukLlmZ1Hs93QVbFDlR84N2XtI35TTywFDZUlohP1Rz3w+9Oc5gWR7os0Y
         W4mTl7gcKux19/XxiyzgwmKPUXSOhyuw6l/BkQ2SxVWeJ2x7uD0GeDMGnYXe09G97dr5
         I0N8/13H6WeAMXR1wii0qcGzqbotBJKTHAdzJ9t5VQ/s8stR5yIl6YiVjlsg89kbzPc0
         s3JRFIXiJWrJlfTMtKVhJzwg2hpc8J0hDKVFjnRJM1esQiZdEw2nDAo64k9E5bKt1SA+
         HOumS9FpE2+Txi5gq8iwvqqIa2xUvVh2kjXllS/xr8hLisV4hIuJX6Kgh6qylAmlLwG6
         WhAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="bqv/NYzz";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f68sor56799735pfh.22.2019.01.29.15.19.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 15:19:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="bqv/NYzz";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yVMgdFOdFa/I4N9PyKEfemOmqSGsE9eLQyaSPEIZUh4=;
        b=bqv/NYzz8Z3PfkBSZ0khR8s+Ikhv8bAjGDfZfAsKr0cYvLOvNl4p/lBENoK9jKtbBK
         0LGqePzhjJWF5MiCmkzcv4QzIsRtMaj5udtxUzNLGbf1T8Z0rfBSmwfVB/0+hTirJliZ
         iXCm6G6KehvWDNx9UXzEykSO/gvHCswwf9M0nQKFaCaNwiSUxJbqzhQ2I3/9ic7JNhTd
         db2AYu6ZHsP4Y06nGP0QrV8ql8TYVQLcqKVx2Fw/kY3ifjOcv2nzdy2OTKOORiDM0XBc
         m6dd0h9in9bbLz+V52UpSmW29qADs97NMsBJ+7ianAaBq+tX0zxyTy/YtZ4ScMR3YgFY
         nfWQ==
X-Google-Smtp-Source: ALg8bN4vlgs6Ey3qXoCP5xMjiItYK8sdOidv0+c3ThlHFIF5qREgv8R63M+FeNhEYyAZGVWSBxZLZw==
X-Received: by 2002:a62:9719:: with SMTP id n25mr29096346pfe.240.1548803945424;
        Tue, 29 Jan 2019 15:19:05 -0800 (PST)
Received: from ziepe.ca ([64.141.16.251])
        by smtp.gmail.com with ESMTPSA id k129sm45370743pgk.29.2019.01.29.15.19.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 15:19:04 -0800 (PST)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gocel-0001Oi-7U; Tue, 29 Jan 2019 16:19:03 -0700
Date: Tue, 29 Jan 2019 16:19:03 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org,
	dledford@redhat.com, jack@suse.de, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	dennis.dalessandro@intel.com, mike.marciniszyn@intel.com,
	Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH 3/6] drivers/IB,qib: do not use mmap_sem
Message-ID: <20190129231903.GA5352@ziepe.ca>
References: <20190121174220.10583-1-dave@stgolabs.net>
 <20190121174220.10583-4-dave@stgolabs.net>
 <20190128233140.GA12530@ziepe.ca>
 <20190129044607.GL25106@ziepe.ca>
 <20190129185005.GC10129@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129185005.GC10129@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 10:50:05AM -0800, Ira Weiny wrote:
> > .. and I'm looking at some of the other conversions here.. *most
> > likely* any caller that is manipulating rlimit for get_user_pages
> > should really be calling get_user_pages_longterm, so they should not
> > be converted to use _fast?
> 
> Is this a question?  I'm not sure I understand the meaning here?

More an invitation to disprove the statement

Jason


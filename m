Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96DE9C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:44:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B6B72063F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:44:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B6B72063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 130C18E0006; Wed,  6 Mar 2019 13:44:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E06E8E0002; Wed,  6 Mar 2019 13:44:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3B178E0006; Wed,  6 Mar 2019 13:44:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id C77CC8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 13:44:03 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k5so12480473qte.0
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 10:44:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=ElWYEbUR+LJ8psNBo+UBE+XENynV58Cm2Tj5h8sRHuU=;
        b=PfFdpX6KxKW/W2fSlKfRWD/Qqkt2Q7um9eUyCWgCsjS+VoGc1Buf9QssI8Le3rSJTb
         OnWqBMTqnqfY4LAqzju0lMPFeCHClQWOv1Fs1Rslw5396PgkmW2yiZTi7egmRzr/HBSU
         WsD9PPzdmMAxBYjGFKswDkKdA2hxskke2Joq5lLD4RUvWjHS5b1vb7bUIt8OfLm8nm0t
         +j7OmG1/GnoepejrzlKnPveV78eMfjGcpE7UlMrV72fSpEarWoauRZvkKykbOeQ/08kz
         7Kf9wvsLp73O0p3ZnGaQEy7iqfmpUEVJ3FPkITS1q7h1zPi1V8lAZ4dF/mxsQToUjtVC
         z+Qw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVQzMGhk1PFDKCUY6IUXjgPCaKiA6i+QvqLMrWdJc3MJViVHYeT
	ez2z/8tt+6nVDtpsmj7/YMJn3dD398CQQ1Ocr9hVGXCvs4NkrPM39LyEAvJNLHVbpUTRSK+7/xr
	sDUtYf9oDXHNlyY2fDs0WTL20Wc0Qi6ILt5cC2iKuOusgRtFl3UoJBUc8mj1AhTan/+lkni1T3k
	h7fV8NnuJvUv4xWN3t9X7bpWLIhB8ASBFZ5VNS5l6LgjSnzc4q5e6IYj1olDLQswxr9GROXGzf1
	wV6FmoEvahpX48Lmw2bcYPwihx4Cm8KwK6/YFQyZkWUNfMcnoJKq/3YjcbXXBOKH/NFia2U2GJY
	pVvb2BZW4ENdxppjkF8jaNxDasDpvUJnmApTo7m10yWlqqMVwLV30wc3tEAiw35wT8ptJOALzbH
	6
X-Received: by 2002:ac8:1ae9:: with SMTP id h38mr6914709qtk.229.1551897843610;
        Wed, 06 Mar 2019 10:44:03 -0800 (PST)
X-Received: by 2002:ac8:1ae9:: with SMTP id h38mr6914667qtk.229.1551897842969;
        Wed, 06 Mar 2019 10:44:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551897842; cv=none;
        d=google.com; s=arc-20160816;
        b=Kl+Pl8RGUBpIPxIiIK6LAOq/oZep0xsGrU7Di2pWxkw/gIIFneNGf/Pgl6u56P/Pgh
         /bq2oA8TJu+zii4NPkIw45fwyahzz6suwTGPqeTDXQi28hjWwM57EXwKayye+jl1AM/i
         tBK0kGXRbHvXDGadbQF53aXGZU9nm0Sa1vEgfIKQ8YBy0m6nszFqxTf0zf0pq/Pqipl+
         R2JchytKEjJWq4F3wL8T05+KNgdnlbY6ouMVJx+EeOV3S7Z97g4vQLfumC5b7OPetX3A
         W9WgUhIaBQpRHQN2qVGXwIR1kzn+GRnAePCzSY0kosfX8QeFwbncBQtwgd6KoZigmk3x
         ogXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=ElWYEbUR+LJ8psNBo+UBE+XENynV58Cm2Tj5h8sRHuU=;
        b=kFcS4Xy9qpHayPeW0F6TBQt+HO0i9MGlTS2ZuKANP7FV3a+hRN+Wow1rjIq68mQOns
         F9zwGKpfJJibVkAvhiWd2Aucm3+iBeOuTF1EFefyMheIIvR9I6IMiRPt1qpt1qtZ9rPe
         mZXFR1FF5AMwUC3UzTMJ7U3M6n29X8jDBywi5OQljHRtge1vnGjvPTsF7u6XpGwI+GHO
         u82d6dKkC7s3ngwTZ3ERTtvuRA4sITtTtepq2dLTXzbEEJyLnYtYEKSRaJsxa0PhpamZ
         w5stZA7HGpJEDHN4xLeZLWweOPcv5u/KJQ/3K8igEQYIkw+Y04ASyOdFxOnO8JrGdcgq
         j8Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e36sor3108640qtb.9.2019.03.06.10.44.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 10:44:02 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqx1S5gxMGG/ZIr9Mgd5jOASSHlQiWpFnNXemR1qMOJ1Cqpi1ovg9QSTLOYr1mZ1E01oTFaexg==
X-Received: by 2002:aed:3687:: with SMTP id f7mr6751880qtb.147.1551897842755;
        Wed, 06 Mar 2019 10:44:02 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id 55sm1539763qtq.25.2019.03.06.10.44.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 10:44:01 -0800 (PST)
Date: Wed, 6 Mar 2019 13:43:54 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
	dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
Message-ID: <20190306133826-mutt-send-email-mst@kernel.org>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:
> >> Here are the results:
> >>
> >> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with
> >> total memory of 15GB and no swap. In each of the guest, memhog is run
> >> with 5GB. Post-execution of memhog, Host memory usage is monitored by
> >> using Free command.
> >>
> >> Without Hinting:
> >>                  Time of execution    Host used memory
> >> Guest 1:        45 seconds            5.4 GB
> >> Guest 2:        45 seconds            10 GB
> >> Guest 3:        1  minute               15 GB
> >>
> >> With Hinting:
> >>                 Time of execution     Host used memory
> >> Guest 1:        49 seconds            2.4 GB
> >> Guest 2:        40 seconds            4.3 GB
> >> Guest 3:        50 seconds            6.3 GB
> > OK so no improvement.
> If we are looking in terms of memory we are getting back from the guest,
> then there is an improvement. However, if we are looking at the
> improvement in terms of time of execution of memhog then yes there is none.

Yes but the way I see it you can't overcommit this unused memory
since guests can start using it at any time.  You timed it carefully
such that this does not happen, but what will cause this timing on real
guests?

So the real reason to want this is to avoid need for writeback on free
pages.

Right?


> >  OTOH Alex's patches cut time down to 5-7 seconds
> > which seems better. 
> I haven't investigated memhog as such so cannot comment on what exactly
> it does and why there was a time difference. I can take a look at it.
> > Want to try testing Alex's patches for comparison?
> Somehow I am not in a favor of doing a hypercall on every page (with
> huge TLB order/MAX_ORDER -1) as I think it will be costly.
> I can try using Alex's host side logic instead of virtio.
> Let me know what you think?
> >
> -- 
> Regards
> Nitesh
> 




Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B70ECC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:15:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7131321B24
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:15:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="EtoIsmNk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7131321B24
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C23F8E0121; Mon, 11 Feb 2019 13:15:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14A398E0115; Mon, 11 Feb 2019 13:15:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2B9B8E0121; Mon, 11 Feb 2019 13:15:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id C78A58E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:15:46 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id q11so11720081otl.23
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:15:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ul5thXc6++/JQFU35y5jSqKTerpNjS/zr14LWC0b/Yo=;
        b=SV7NCXTbYMwg1yuqyCHWo2NZNtoYqXbW+RMgOxK/l5bLzXUeKfnsCUZPE07XZcUggN
         h4eBU9BUaUK+BD9ZY4Ns0CCNaf0f1vdEYrWvTxgOCV0ju9vZA3rlJUbnAlXiNmitIDqd
         gDixk3ZRWfDnF1ofXfVQH8Gn1BwKmRDPyUrq9jm5/1pYFxJNo9gCknvrcVGyQvEjakig
         ELIABqZXQnZUi1eYBVwU+oEpa4tyWw6IVxpsd3J+sSHXMx1QPaLaXs2hntpuDVfRu8jZ
         lnWhssI0U49cAfWDv5dB5kObF46CPgVohDL6mtq7IMEIQMikBVSSLtOhdoBHtXbqA1/U
         u7MQ==
X-Gm-Message-State: AHQUAuZwnN7Xtn1ucoJa25W46TOzdrFU1PaqSLEIcSEplm6CHHdhDV7s
	C5ODp3T8KO2sdPA6h4XF8LJg2qdVtOwLmqYnF6Q1cDvCOF7brfrQzwH5AeoCjZd/49Mk3XaD72p
	CNJety6LEXkz3HKj7HYalXLy5atrc8j6hjbLcvlk2/BvJXhEB4dg255aWHfbsfJJV4cG5tf60GC
	ONt5Rrc+ozuCMQ5CHU3YxwOxGqIPMiGwXPh9j5Jxx2DftLhg6z/g83dC26zxdz1I6OvBXFxLb8q
	Nj+T04HDkEFQoqBSJc6w8dN1KfBE9BeQz2qqmNOgPwObdxCDoEhB3FSToJJmonsB3VZUbCR1uwN
	cC7CmG3dVTIhCgzjff+hOf86G9aeoV6rJRBCzr56Oq4kVnrP/HonHThkDWgJbch/GP16au7t/6q
	q
X-Received: by 2002:a05:6830:1408:: with SMTP id v8mr11024754otp.211.1549908946364;
        Mon, 11 Feb 2019 10:15:46 -0800 (PST)
X-Received: by 2002:a05:6830:1408:: with SMTP id v8mr11024663otp.211.1549908945303;
        Mon, 11 Feb 2019 10:15:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549908945; cv=none;
        d=google.com; s=arc-20160816;
        b=LNqAZp6f3D/JcChv7zii+qZPUwOr8ONM3f0UGcjxh2dHVK2Ndh0WDqCaIAv15ZYKwK
         dnXo1WxMJ/v92mOrPP8jdYaxaEMGaM08xSp44j0aUYq2CcyqcwyUoIveTUw89vNYWO22
         m4MmAeeL0WB9chZxncwW0pcxM5iZk3gq9Yc4nPv/2AXZIr2PP8cEvfAJMDjDpSHpf41K
         8AWNUzy5b07i+nJiuqQ9nWFbn+8nkmXviK9xTDLAr3df1g0VGh+feXJva+i0AR0maqDp
         bZWuJPnD8jX7NjYsMHCehU95t4TXMpGI5G0lyORYmHsgOofYICr/EycQLVCV0Jl10d7d
         NreA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ul5thXc6++/JQFU35y5jSqKTerpNjS/zr14LWC0b/Yo=;
        b=kVK0jTB6o8PMRT4ohTZfvDB0oVIIg61cVNspRtp7SXafhsoPxSs3YuvBaM9c8hg+3M
         EFn9WzpEgcEGfN6gYT8jeI31eKa/S91XzWq+aSSRZdR3NgEnaEWBJbhBTJHOfRtkKgaz
         NLM+D4SIb2ShGxMvNo3tXxqfGZc5zD+OlW0JMQzv2YnAm8z8sXJ5j03OcsNGciOCGFfI
         tKS0g2srcu+QK5SfdGxw8YGQZ0/5ouApfOIbyLp8xxA6RctrJOtBtaJE3RrPEEZrXAaL
         S0Gn0b2N50jrSEmX1xuvB49xhLv/D62XQ5k2FzeGbjV/7oD6bJbfpS2grWDRAJ25heSJ
         nPgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=EtoIsmNk;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z5sor7440761otm.164.2019.02.11.10.15.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 10:15:45 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=EtoIsmNk;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ul5thXc6++/JQFU35y5jSqKTerpNjS/zr14LWC0b/Yo=;
        b=EtoIsmNkDKQpRH9ypOI5wOHAdlLYheZn+QoXMnH9j3ESgJ+H9ofHEeQ2+z0WgQiKEr
         x9nF4ZYK4if03fgMSHrIocO7JgQkq8nUlENbhQkgchPEbtsIq8nWqKuoL+Jovt6l77PC
         N7xGDCZnhMddxom8jz7HGzV8UCnt66iV8NXbA1KODSySGADwC0E5Y6CoZ4HYts0xJDyd
         4crFfr0dStfGbzratLctbDnEN4KBjQvGMpQEabs0lF0hrPbIYi4QZy7IEaBYhZer3x73
         HknObt5JsH4ENZsCqWCBSk5ZIQ9H6iR5krsJEj/meW/V3iGfAGNFHjvjw7Qs3eii4g1d
         XMYg==
X-Google-Smtp-Source: AHgI3Ib8Tv/GTd/LyyhnRUStQh32TJGMr1mf9h0L5JluLyTEcL0lx7jgHtIyGdtYh7vMLGodX085tmaC6phK3LYN9V4=
X-Received: by 2002:a9d:6a50:: with SMTP id h16mr14708887otn.95.1549908944982;
 Mon, 11 Feb 2019 10:15:44 -0800 (PST)
MIME-Version: 1.0
References: <20190206220828.GJ12227@ziepe.ca> <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz> <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
In-Reply-To: <20190211180654.GB24692@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Feb 2019 10:15:33 -0800
Message-ID: <CAPcyv4hdVwn0L8060_wxqDV0XBOwiUojSYjF+u+ugzLoQpcHzw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, 
	Christopher Lameter <cl@linux.com>, Doug Ledford <dledford@redhat.com>, Matthew Wilcox <willy@infradead.org>, 
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 10:07 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Mon, Feb 11, 2019 at 09:22:58AM -0800, Dan Williams wrote:
>
> > I honestly don't like the idea that random subsystems can pin down
> > file blocks as a side effect of gup on the result of mmap. Recall that
> > it's not just RDMA that wants this guarantee. It seems safer to have
> > the file be in an explicit block-allocation-immutable-mode so that the
> > fallocate man page can describe this error case. Otherwise how would
> > you describe the scenarios under which FALLOC_FL_PUNCH_HOLE fails?
>
> I rather liked CL's version of this - ftruncate/etc is simply racing
> with a parallel pwrite - and it doesn't fail.
>
> But it also doesnt' trucate/create a hole. Another thread wrote to it
> right away and the 'hole' was essentially instantly reallocated. This
> is an inherent, pre-existing, race in the ftrucate/etc APIs.

If options are telling the truth with a potentially unexpected error,
or lying that operation succeeded when it will be immediately undone,
I'd choose the former.


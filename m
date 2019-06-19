Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71B09C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:46:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3595621537
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:46:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="eEIpXOcP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3595621537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C581B8E0002; Wed, 19 Jun 2019 12:46:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C09918E0001; Wed, 19 Jun 2019 12:46:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD1158E0002; Wed, 19 Jun 2019 12:46:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82CFB8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:46:36 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a8so8140651oti.8
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:46:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dAeca+NaeasgKg8wLjwxe/d8KFhZwiNtk4NpQn2oH10=;
        b=o18HPHcMJVsX1AA850XGCIBgB1rIlqFcZ+8hJUPdC95+oEKZzodES4BH/6XouCfo/i
         3APxAUTnktoGcEMGriJjB62NIGaUuGS2PQob/E/jHi6cYYDF+x7Xw0Ca76nPDbT4md0R
         znS6FT5A8kdKTwVugUmUJCQcVQy0qlPhU8OplnaXK80pWcSgWChRNNF2wpF4iVkYnqVM
         t5DeaPf8iFx3NBBfkwIlBydwR9RRtrslrsK/nxxR9Ufst4RNbq/FwAm/Vu6RPQT2UEEE
         zIGdxVvXEleSpo2ajoRmYWKK6W8EdNsaV56SnoPy1jRMIwbQEnVS3YcpEJP1b9EQJDqw
         mF+g==
X-Gm-Message-State: APjAAAXpqxBairpSjY6yf+lgbk46YIWjuc5QlfEqRHMrBmrFOmrYFyyB
	8BusNCeF2GOGBhgnxwIk9aLifDjnFwOdRrAUbwncw4w8AppuGsOipDq5pUXBYMGVUvvoKyL/Fas
	snWeX0wwNldpF96NGNPTNMz+QjxAG3/kL1WhFC2PZwNQdxQybZzyrESXuYbKDOQrjqg==
X-Received: by 2002:a9d:7a46:: with SMTP id z6mr4068666otm.2.1560962796090;
        Wed, 19 Jun 2019 09:46:36 -0700 (PDT)
X-Received: by 2002:a9d:7a46:: with SMTP id z6mr4068573otm.2.1560962794561;
        Wed, 19 Jun 2019 09:46:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560962794; cv=none;
        d=google.com; s=arc-20160816;
        b=jFvXe2kAzcWCnmFqlqs/F0vlSvsxE0msCefmc77xvCjhhup/SdBVoX4jgVzaAj7UuH
         riovvwVHtcqKJjIj5/z7sCZNMKL7czrqp6725mzctv4EK2i+tPrgBdtqgJu3I6CjOJQs
         BSyG47iDnBvBdv4/sZnHhFsooL+uVOi43NaWMd9gOR/0scmVOviaY+2fXA63Kr9HMdZ4
         bxjPGDDKlV19w5z2wZWioj20GcSPLNn7r3GNAE0uAIp55jc0gjuolZirfFLRDZVvXj7h
         /WVQ3uf4a9TCMgbOXp3puBBoy8yUzUU8agWUrPqw7slLupGUbkvLO+awcz/Exae9SLJ7
         DhTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dAeca+NaeasgKg8wLjwxe/d8KFhZwiNtk4NpQn2oH10=;
        b=mhIIRdkq1wCYPA3i+SlO+Yvft5PFSdbuA46fgWRcLkqz/sJ4W4bYIRl+iYP6BkbmMf
         dogTz2kt0cl2DAQBxX5f3M+Qrux6qelr+7g0/abXzLiKX6j9cNHuMbMReZ4dY9zUTnuZ
         XqyQSY3LUlUbA87hv9qRqGgjRuzey+wAabdDEzRqHnMX6jTOSE7wxUXV6gesoZSEioJz
         cAPT3CZ1gTPRuL/TgxK9DUspmRw27hsRxJtqYNt4EglxNRepDtinHkv03hnqH4XATZf9
         j2pGSV24zFvA4AWKHyn/Eg7QHljWnqZMNnFW9/VqEhseADVhqcDSrK63UDUFg3TrNHDF
         e18w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=eEIpXOcP;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21sor8965514oti.14.2019.06.19.09.46.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 09:46:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=eEIpXOcP;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dAeca+NaeasgKg8wLjwxe/d8KFhZwiNtk4NpQn2oH10=;
        b=eEIpXOcPgh/FQm8AcRovuq2bVonIAGIxG4O8hqog+t2sNo8lmrfYIpq/+3PFypMTty
         siI4svCj0XFFk8DvueW2Zz7Zvoia5aS+WjHA2V9kjitsGk2Dr7OrDOGRxd+jgBEHrThr
         EHGL3vlgHvvthlk8Gfj633B1vbDSWX+nCllo+CoYhKFeZWAJNLlFWMmdziVMMg2G+cne
         9LkPYCnW/ZVKV1OTMMtvp9jixEL4J8gu4orI34DCJ30mCCAblY3ezSDjxZuDDDsPUqbB
         ZHR6EtInNGpbX74S1TmPO0TGeYVW9GToDYCY1yWZmGb6+1NQToWu8/vN0HJQG43y5Q4m
         K3fw==
X-Google-Smtp-Source: APXvYqxu7jzERtujGtRB1JUPTrrSRxaJnnRx7A59gFxSd7DNSrReLEw7sHQTmTBvokQEtVRT1Qlvl4tg5ll4Z2fBIRs=
X-Received: by 2002:a9d:7b48:: with SMTP id f8mr9700022oto.207.1560962794186;
 Wed, 19 Jun 2019 09:46:34 -0700 (PDT)
MIME-Version: 1.0
References: <20190617122733.22432-1-hch@lst.de> <CAPcyv4hBUJB2RxkDqHkfEGCupDdXfQSrEJmAdhLFwnDOwt8Lig@mail.gmail.com>
 <20190619094032.GA8928@lst.de> <20190619163655.GG9360@ziepe.ca>
In-Reply-To: <20190619163655.GG9360@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 19 Jun 2019 09:46:23 -0700
Message-ID: <CAPcyv4hYtQdg0DTYjrJxCNXNjadBSWQ5QaMJYsA-QSribKuwrQ@mail.gmail.com>
Subject: Re: dev_pagemap related cleanups v2
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 9:37 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Wed, Jun 19, 2019 at 11:40:32AM +0200, Christoph Hellwig wrote:
> > On Tue, Jun 18, 2019 at 12:47:10PM -0700, Dan Williams wrote:
> > > > Git tree:
> > > >
> > > >     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup.2
> > > >
> > > > Gitweb:
> > > >
> > > >     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-devmem-cleanup.2
> >
> > >
> > > Attached is my incremental fixups on top of this series, with those
> > > integrated you can add:
> >
> > I've folded your incremental bits in and pushed out a new
> > hmm-devmem-cleanup.3 to the repo above.  Let me know if I didn't mess
> > up anything else.  I'll wait for a few more comments and Jason's
> > planned rebase of the hmm branch before reposting.
>
> I said I wouldn't rebase the hmm.git (as it needs to go to DRM, AMD
> and RDMA git trees)..
>
> Instead I will merge v5.2-rc5 to the tree before applying this series.
>
> I've understood this to be Linus's prefered workflow.
>
> So, please send the next iteration of this against either
> plainv5.2-rc5 or v5.2-rc5 merged with hmm.git and I'll sort it out.

Just make sure that when you backmerge v5.2-rc5 you have a clear
reason in the merge commit message about why you needed to do it.
While needless rebasing is top of the pet peeve list, second place, as
I found out, is mystery merges without explanations.


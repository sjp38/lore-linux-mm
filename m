Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 597ACC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 10:03:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC22220842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 10:03:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC22220842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 683538E017A; Mon, 25 Feb 2019 05:03:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 633358E0179; Mon, 25 Feb 2019 05:03:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 523A68E017A; Mon, 25 Feb 2019 05:03:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3398E0179
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 05:03:43 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id b6so7388333qkg.4
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 02:03:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LrjL/IR/nPYy50l3KNWva9W7bkO6339NN2/Hjcw8U3Y=;
        b=CwqD16bMLqxJMDKB3SkpVBnrwNoIBXf6QbK3Fkhfdq3xEVlVKyyzDzCzK1kJidwYQl
         JXdnub4n+QyyV95Gw6CkQ1E9G+50XnihsMvpCdlepFNybzLErC31m730YlV1XD8v4q7E
         qm2ShuYymWFyJdlfEpjiMwXEvOKvomRmtEt3lgzlTa6nxGey3EOR4xuCJluwFr+tSXrH
         GIGtSStl09AAlddqwlpy1dR+HbUX7m8dAUhOGZRg8NrSZ/4Qu+o6J4O4Ee/W2focJf/w
         PPPeIt4kRTbBJY6gmbfbNlTIEyWDwveM9d4N9dYfjfH0mfHNZ5kQmQDfAtaH8Uk4Hafk
         wCRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZPyjlNdYlbYFTGFeIbCMUcSy6zpaFtuUQeBTU8V/N0goaz2Xuy
	orfSAQPenTNQHwnAdkT38XjTxfdeAU9O9SK2dsF+1VsWVMDx0Z6RN6g7m9SWxd4NMxWeTvomJ4h
	iK//Gggd4N9Xmj436FDW5ZF+OzeFhLcukft47MtXGOWrdI1f2pU0pDDHmcMUdXIeugg==
X-Received: by 2002:ac8:3718:: with SMTP id o24mr13052156qtb.2.1551089022860;
        Mon, 25 Feb 2019 02:03:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia7w9JWEg8N1Ufmcy86z2xdg3lQapzci/8anqbZZHF8eAUX4/+b4+FbxU0yxwOde6KDJB/e
X-Received: by 2002:ac8:3718:: with SMTP id o24mr13052106qtb.2.1551089022003;
        Mon, 25 Feb 2019 02:03:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551089021; cv=none;
        d=google.com; s=arc-20160816;
        b=sPh6HYMLdYbdm2fFcf3kcEhARXmzGM0JOieBN4P+bXp6uTtgblk7HmCyFiTT0yHhtE
         rpQ71vMjO/3MBWOOiIcB3radr86H8phqpHuKywNVB/dlqi2hDbWkZtcaYWeYl68M1NAw
         t3mVak+imf0eE5KGxFXC6hilWSyWrPyrI6LJy0F2rz+neVwYT2ScMCIwh2z2E8pnLXYg
         friHclpUBERWC0O3kvqeQ5ldMQnRkgJl4ULBOeDITseaV1EeOw9yvEuPzxEGEZ0vL9Y1
         Nadr1EtRDsQuh1j2GPeqNNTHJFkWntY+P2GnalkMEs+J95gSY8YV0hCba2QBoBUlhYL8
         Ta2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LrjL/IR/nPYy50l3KNWva9W7bkO6339NN2/Hjcw8U3Y=;
        b=vMlPdBsAe2XHXLcp8B1EVY8UWDXJaUm012kEN854pHUtjZKMOLQ/NSq6pid0YQ76mx
         Zkca7+6owlRaBSzx6azV+SQ+LHyAnt6nRDwTUGswS+tnAu0zjdc5DV8RAqSQx2DBYUV5
         6oXlN8M3rSooIEZIcpNIzXu68VkWZSVcz81l8k+HwtlvZvzPR+RWLXfJdlUzBR5dqIT1
         4OXR0x82GRFPduWSbrcyJzEOHE8LZirRqu2Qn1iMysbnJaq1AMR6THC9vFyHcdH5TXxY
         BctiAQiP9lodI0UP7WhH8JbfYrdZCLHHta8TyowSkZ2yj7EhE9d65Kx9JoGc5AmSXQYP
         ONQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f12si1158517qvh.98.2019.02.25.02.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 02:03:41 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 14BBA30842B1;
	Mon, 25 Feb 2019 10:03:41 +0000 (UTC)
Received: from ming.t460p (ovpn-8-31.pek2.redhat.com [10.72.8.31])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DE8531018A04;
	Mon, 25 Feb 2019 10:03:31 +0000 (UTC)
Date: Mon, 25 Feb 2019 18:03:26 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org,
	Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190225100325.GA10093@ming.t460p>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <20190225084623.GA8397@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190225084623.GA8397@ming.t460p>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 25 Feb 2019 10:03:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 04:46:25PM +0800, Ming Lei wrote:
> On Mon, Feb 25, 2019 at 03:36:48PM +1100, Dave Chinner wrote:
> > On Mon, Feb 25, 2019 at 12:09:04PM +0800, Ming Lei wrote:
> > > XFS uses kmalloc() to allocate sector sized IO buffer.
> > ....
> > > Use page_frag_alloc() to allocate the sector sized buffer, then the
> > > above issue can be fixed because offset_in_page of allocated buffer
> > > is always sector aligned.
> > 
> > Didn't we already reject this approach because page frags cannot be
> 
> I remembered there is this kind of issue mentioned, but just not found
> the details, so post out the patch for restarting the discussion.
> 
> > reused and that pages allocated to the frag pool are pinned in
> > memory until all fragments allocated on the page have been freed?
> 
> Yes, that is one problem. But if one page is consumed, sooner or later,
> all fragments will be freed, then the page becomes available again.
> 
> > 
> > i.e. when we consider 64k page machines and 4k block sizes (i.e.
> > default config), every single metadata allocation is a sub-page
> > allocation and so will use this new page frag mechanism. IOWs, it
> > will result in fragmenting memory severely and typical memory
> > reclaim not being able to fix it because the metadata that pins each
> > page is largely unreclaimable...
> 
> It can be an issue in case of IO timeout & retry.

The worst case is still not worse than allocating single page for sub-page
IO, which should be used on other file systems under the same situation,
I guess.

thanks,
Ming


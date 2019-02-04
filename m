Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E006DC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 16:59:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BA6720815
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 16:59:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="PczSozFF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BA6720815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 341CA8E004A; Mon,  4 Feb 2019 11:59:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C8588E001C; Mon,  4 Feb 2019 11:59:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16BD68E004A; Mon,  4 Feb 2019 11:59:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA6778E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 11:59:18 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c84so478785qkb.13
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 08:59:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=dFVSi6eAG6s4EOjNzfgj7jQYa7+0xeruK9bRGAAvn/0=;
        b=Rb+OzDo7CM+oIpoQjQFMcFHgfp5t6Dq93rHrpCpgu1Aa8dLXRWwXGNf1bMyGtyC9bF
         HVX7Swogd6PZbJcWKQmUeo20j6XIvk3MisdUahi7UROGuUGf9Vgruu5ggBoa51hRZpX1
         rdVc8wh46V+WyB2b0Ww5ONye6Vk/pMvrXI23EsadhzmCLw6K+21LRLSow7t+B8BWALWG
         fTik8yCERBpdK2bIsnmXs4rhK3CXnUdyMVLZ7g+TxTur9mUdQtptmyceCy81tKgJ3Jqj
         AuyIX0+O1cFIrg8JB3fLl6ACsdHSY8zIa5pKd/0Nw60uNz3SPM8ty4nfLDaDU3QZB8b2
         Mz/A==
X-Gm-Message-State: AHQUAubR/J2Jcla2DQpMYI7hem1HVvrKefBQcDydaz0FXi7CIkyunVuN
	52JAZxot9mq/bh1uF/Tj3yXB/7PggvxZv5GZ2d7782JXQNfkSe/W+RiRDiooSrraJEvjq+cSR1f
	34anDmpyjLWCuOBdkGUQ46jYguxFVjV7RLvh/AV/nB2Z4UNDCs5BSbTBq01ihXVk=
X-Received: by 2002:ac8:26b9:: with SMTP id 54mr245719qto.301.1549299558584;
        Mon, 04 Feb 2019 08:59:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IboXJbFccKQo+pygfaIkyoTNqiiEUFufPcjuiuldC4cIt+S+9K2lcJ2t1/1N8tprxUAv/zH
X-Received: by 2002:ac8:26b9:: with SMTP id 54mr245674qto.301.1549299557964;
        Mon, 04 Feb 2019 08:59:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549299557; cv=none;
        d=google.com; s=arc-20160816;
        b=J/G9/Q0A9heX4Opk2yilpQXhu5Pgm5JoTzg8YszNRqUrW6vtOQghs9KATP9QVLY32m
         NKyU2ctBwLuFOykkGvPbfp+UATM1u/BfsECwav8Cl36aISv7ZygOsd38sJhR/RLCUazX
         npy+a5FycAvxVLp7uYma/yJ4K9AxEoG5J6QHSSEKWoHSPkn9otKOWaZlNjQbJuW3gsWE
         08W7EcJjRFOwnZ+VhtjD3cpcZe1OUMbge3BCnE3weTSIDSOZeIdCUpVfEFK+AaNTwzml
         J8iflGkytpWWy+Ip0PziHTxdWpOF0CwbZQDv49emAm886cfkNIOTobsCFHMP9YO/L6fV
         97DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=dFVSi6eAG6s4EOjNzfgj7jQYa7+0xeruK9bRGAAvn/0=;
        b=orC/n+UHEmuhMg6JDWhxTJhSFrzzRJf5Fzr3YnyJF3Lqc653d1vmdOFmyElBbHIisA
         XUJ95eAAR06IFyF4PpX9zJml5yoxMLMkESf6GtTQNKikIFfTkDPck5iy1rlw7X52PLRM
         xQpq9q+3WG+a2zTKvhYVQcaenMCt/2Z7uSwrKN1lyBPNJmhYnAly47FNId7jZGV/Cgu5
         QwiqxCsx7YDx7WkGo3mNJ2Pn62HsMkCVfpMLmpDAgrpTwQtLWH+pe6hFYR6vpsymaqRT
         fx3hc5rhZfdgCvLwTEWigHsLMTOcTDlelUcGlp9E6GPvbVXE0I7uoxHqn69o/NPrpWOp
         tg4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=PczSozFF;
       spf=pass (google.com: domain of 01000168b97322ff-7c681a52-566f-4de1-ba1e-0a045b7f3622-000000@amazonses.com designates 54.240.9.114 as permitted sender) smtp.mailfrom=01000168b97322ff-7c681a52-566f-4de1-ba1e-0a045b7f3622-000000@amazonses.com
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id 13si3836613qtu.390.2019.02.04.08.59.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Feb 2019 08:59:17 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168b97322ff-7c681a52-566f-4de1-ba1e-0a045b7f3622-000000@amazonses.com designates 54.240.9.114 as permitted sender) client-ip=54.240.9.114;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=PczSozFF;
       spf=pass (google.com: domain of 01000168b97322ff-7c681a52-566f-4de1-ba1e-0a045b7f3622-000000@amazonses.com designates 54.240.9.114 as permitted sender) smtp.mailfrom=01000168b97322ff-7c681a52-566f-4de1-ba1e-0a045b7f3622-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549299557;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=dFVSi6eAG6s4EOjNzfgj7jQYa7+0xeruK9bRGAAvn/0=;
	b=PczSozFFqeRL7X+LTVq/x4SUbvHWdcH7f444zjDojJHuUSurhYyjMpazh91nqYfc
	IaVvmvTRYQS6v/LqWHm6LnWzaz3MZ89JxulkbSfH0GWidNhdvPRq1ddxLuTj2iYqGSM
	lkgO3lvUPBKUvTT6vy7WFXpTOY6Rt2jkSXfkysN8=
Date: Mon, 4 Feb 2019 16:59:17 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Christoph Hellwig <hch@infradead.org>
cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>, 
    linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, 
    Christian Benvenuti <benve@cisco.com>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>, 
    Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, 
    Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
In-Reply-To: <20190204161201.GA6840@infradead.org>
Message-ID: <01000168b97322ff-7c681a52-566f-4de1-ba1e-0a045b7f3622-000000@email.amazonses.com>
References: <20190204052135.25784-1-jhubbard@nvidia.com> <01000168b94439c0-28d5e096-718d-4e39-a7af-20d0a6d7b768-000000@email.amazonses.com> <20190204161201.GA6840@infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.04-54.240.9.114
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Feb 2019, Christoph Hellwig wrote:

> On Mon, Feb 04, 2019 at 04:08:02PM +0000, Christopher Lameter wrote:
> > It may be worth noting a couple of times in this text that this was
> > designed for anonymous memory and that such use is/was ok. We are talking
> > about a use case here using mmapped access with a regular filesystem that
> > was not initially intended. The mmapping of from the hugepages filesystem
> > is special in that it is not a device that is actually writing things
> > back.
> >
> > Any use with a filesystem that actually writes data back to a medium
> > is something that is broken.
>
> Saying it was not intended seems rather odd, as it was supported
> since day 0 and people made use of it.

Well until last year I never thought there was a problem because I
considered it separate from regular filesystem I/O.





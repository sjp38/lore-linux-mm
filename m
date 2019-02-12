Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0CC4C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:34:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5D1620855
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:34:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5D1620855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 608E68E0002; Tue, 12 Feb 2019 11:34:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BA2C8E0001; Tue, 12 Feb 2019 11:34:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CE258E0002; Tue, 12 Feb 2019 11:34:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0ABA98E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:34:37 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id cg18so2610326plb.1
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:34:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nwHEhX651NKR4J/IqzBdizFL7Fd9ZYvXs4LuumuIM2k=;
        b=cveo55ZiyQAHs0FYXyxUARm841W3UsBO+ZG5KPDQFr8iF/I0y4bEgwX5xzV5zjq2ek
         USs6Z/NwX8UrYhKPd4tsCvjmyQpXVtC/CSthM0dYhzI2c3IS1hA3kIXBwmPA1sIMRgK4
         ZdKruM+VGJDFpc9SbGH0nyQRwbLguPGSshp3gkjlfQm3zve93Q9vfI12idE+IGLEC7T8
         +FKyXNp1jD4CrAwUvj2H+XHBBhFheXYDyy5V0hfwbHJ1Ah2rOxGjsR7E5d89Wnv1YIYB
         bx9Yw73CINzFQnN21y9bV8mB2m5Hj/yVT3UnrBd7K8ANrNySGGI8MvfCFh9sUT9CN880
         ec9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuYpA2KopzeiMrnqfVIOoAusd1b8Xi1QhUw8Ftg0WbcqoLxtkXvB
	JDItIMdTp2Qs9X89+yErmcrRKOXyL4uxRF5AhOGtT53Ii9h7tZulzoPAs/UoQnlh5WnmVp1d7rW
	FmHxoJSwdYtUknoAbuMWpXbGLpkU7QEeYGFOeV8BafdXHNI+zdmfbKAIT37ZxeE5LQQ==
X-Received: by 2002:aa7:82cb:: with SMTP id f11mr4789198pfn.49.1549989276697;
        Tue, 12 Feb 2019 08:34:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib1bPCj2yZjgObvv1OHXtdsOhvm4rqpC+9dbSjqwgSRjgToL26Fuj+eUGG62B/mtEcTOQz9
X-Received: by 2002:aa7:82cb:: with SMTP id f11mr4789149pfn.49.1549989275991;
        Tue, 12 Feb 2019 08:34:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549989275; cv=none;
        d=google.com; s=arc-20160816;
        b=rShNa0CCTm5zdUoRtcZtFjnHHkXPkAq/LRPjvYXGErRFneh4ws5i0YDfVN79oAygrO
         gi6lGFTR6en5h5U93dnqYRY5GXS3F/MLA1o5hGr7PaDsza+0+22ii8sHhjYSQ01DnekV
         SX5r/wh7Luds4zajef5udMaCECuZ/3zGN4kWlj50FAWK/lpm/PjIx7kaQkxKpnOqxnoO
         MGZbosSTHVC6ucE/Xl20RnT6PjjBMgTynHrvuaC3yFFx8Zbf3pR01mdDqzVJK+DcMCHT
         qZnrG8IA32u5ULwYhOnP9DbekudvUeDvQaiQf7Qv3cSoGonvuba3hVRGM+2NmjVN/xfW
         UREg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nwHEhX651NKR4J/IqzBdizFL7Fd9ZYvXs4LuumuIM2k=;
        b=c40BdCNVaZT7uPvRqsLS6zPGz177RgoQIxpgAyCT7h9urGG5ZTdi3ValhTwgVDZsfc
         zvpr6YCPuniGWcfiQKKRCK1GFgbhWExcTNRIcovIuUmmOGQxx6hI/nB/mxd09eiymoiZ
         KpnlmCoXvkmX/QS6b8N4W4UkIxKwhv+9Lh9n+sm6I0G5J7aTi/ViGS1cLKLo86AkPwmL
         GHBsInPSV/xdK8XREx0su8bhDp3CdfyfzlRQ1G7YZypYwiqPWwpiMaxQklsTIUR4JYMb
         /wvyfMesPLZoud+pyC5vasEDzIDVltr0Jz/n1zDYkOGOnKn4XiS6Ffl2I905eEm6i8LP
         sx1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 29si3422272pgw.109.2019.02.12.08.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:34:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C4F26AD17;
	Tue, 12 Feb 2019 16:34:33 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 2ED141E09C5; Tue, 12 Feb 2019 17:34:33 +0100 (CET)
Date: Tue, 12 Feb 2019 17:34:33 +0100
From: Jan Kara <jack@suse.cz>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190212163433.GD19076@quack2.suse.cz>
References: <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <20190211182649.GD24692@ziepe.ca>
 <20190211184040.GF12668@bombadil.infradead.org>
 <CAPcyv4j71WZiXWjMPtDJidAqQiBcHUbcX=+aw11eEQ5C6sA8hQ@mail.gmail.com>
 <20190211204945.GF24692@ziepe.ca>
 <CAPcyv4jHjeJxmHMyrbRhg9oeaLK5WbZm-qu1HywjY7bF2DwiDg@mail.gmail.com>
 <20190211210956.GG24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211210956.GG24692@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-02-19 14:09:56, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 01:02:37PM -0800, Dan Williams wrote:
> > On Mon, Feb 11, 2019 at 12:49 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > >
> > > On Mon, Feb 11, 2019 at 11:58:47AM -0800, Dan Williams wrote:
> > > > On Mon, Feb 11, 2019 at 10:40 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > > >
> > > > > On Mon, Feb 11, 2019 at 11:26:49AM -0700, Jason Gunthorpe wrote:
> > > > > > On Mon, Feb 11, 2019 at 10:19:22AM -0800, Ira Weiny wrote:
> > > > > > > What if user space then writes to the end of the file with a regular write?
> > > > > > > Does that write end up at the point they truncated to or off the end of the
> > > > > > > mmaped area (old length)?
> > > > > >
> > > > > > IIRC it depends how the user does the write..
> > > > > >
> > > > > > pwrite() with a given offset will write to that offset, re-extending
> > > > > > the file if needed
> > > > > >
> > > > > > A file opened with O_APPEND and a write done with write() should
> > > > > > append to the new end
> > > > > >
> > > > > > A normal file with a normal write should write to the FD's current
> > > > > > seek pointer.
> > > > > >
> > > > > > I'm not sure what happens if you write via mmap/msync.
> > > > > >
> > > > > > RDMA is similar to pwrite() and mmap.
> > > > >
> > > > > A pertinent point that you didn't mention is that ftruncate() does not change
> > > > > the file offset.  So there's no user-visible change in behaviour.
> > > >
> > > > ...but there is. The blocks you thought you freed, especially if the
> > > > system was under -ENOSPC pressure, won't actually be free after the
> > > > successful ftruncate().
> > >
> > > They won't be free after something dirties the existing mmap either.
> > >
> > > Blocks also won't be free if you unlink a file that is currently still
> > > open.
> > >
> > > This isn't really new behavior for a FS.
> > 
> > An mmap write after a fault due to a hole punch is free to trigger
> > SIGBUS if the subsequent page allocation fails.
> 
> Isn't that already racy? If the mmap user is fast enough can't it
> prevent the page from becoming freed in the first place today?

No, it cannot. We block page faulting for the file (via a lock), tear down
page tables, free pages and blocks. Then we resume faults and return
SIGBUS (if the page ends up being after the new end of file in case of
truncate) or do new page fault and fresh block allocation (which can end
with SIGBUS if the filesystem cannot allocate new block to back the page).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR


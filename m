Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2E9DC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:19:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CDD221B24
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:19:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CDD221B24
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CCE18E0123; Mon, 11 Feb 2019 13:19:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47A648E0115; Mon, 11 Feb 2019 13:19:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31D288E0123; Mon, 11 Feb 2019 13:19:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0EBB8E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:19:34 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s27so8971951pgm.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:19:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uGDmDXix2BtjNrmEsYuBQ0C+tAu5SM9jxBseggRDzDs=;
        b=fimGpxGkCqteGZnQUuAqO+EWwEyXJpyvj1FquPei78YqQsULKYLxLQrl5nbMmhaljp
         yyiVZ5Qj9iqN7aAeNeH68HfutyhMuEuGW979iJOorAJrn+6MS/6AbVf7poMnj+GKxHH+
         jMGEi9ywahPwPpPGcSEZUgW7gt6qYYb67SXjeQ8t7e7jqkykKRNbIQ36gCLIIVu1hiO7
         zNo1V6zZfoJd7AhdumJ7JqqvBKjV1BlFLldqClSp+Bw7GLdNhIXRFPvxjgrD1iL+8fIi
         C3Y7XRAPz1opv0WZgdQiAEgFVoE/Jk6uk6K0tD09eop/56pLu4YHlDa/UNkuHcCmfbxg
         RtXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubGkzpussAXPdqn/mB3/EHAB4yMthcmmM+uiStNO8aLxbaIpkyo
	qo0k8BuCI5k5nq/LB5chj/zR6Q+fGtZG2w2J7m84GXx6wUx8sNPI2lmSLvEEnL/65RxpBl1SOoO
	+z4ZAToXDB6zOjBipt4ugWXcL+tGJNW4+1z9UjpgOenpM+QU8VKW/4j5duVOMZ5QB1w==
X-Received: by 2002:a63:d49:: with SMTP id 9mr6817468pgn.27.1549909174608;
        Mon, 11 Feb 2019 10:19:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaDNJHchDQBkQOOHz/M3MEpbkkSk5IxW/3yzTXjK65p9A0bFw2HkMvk4LZ4yim348VDpIfq
X-Received: by 2002:a63:d49:: with SMTP id 9mr6817419pgn.27.1549909173843;
        Mon, 11 Feb 2019 10:19:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549909173; cv=none;
        d=google.com; s=arc-20160816;
        b=QeUYlxF2vIuWyOu7ucRKKS36YQc/zd64UUNzNcJMaWZUZfYqWIPKEpdzuw1AK02dLA
         KGGwpOSloe4ZVh9R+CEd7lCeGJ8rNNW6F4aFcoO94u6OpSKm/OFVHaMXCiJMMJayxr5M
         NWfBMMO8TAwOu3SFLIldrMknC6p28DL+kNUmzGOyIz1dBhIzXjEMyFl52Y1C+ctVH8cx
         dpHMjLGlj69kXYmCzo749A17ggvTTSU9INsA3lLvqAkLD3rA8AbZE+sXxiWwlrBqaxWC
         7Eg91k7PNNqNDMWm88rvmUvM69a9/bDujvsQc5ONOZZJYee9v6o3t2hgjZcNshIjpsVD
         90Hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uGDmDXix2BtjNrmEsYuBQ0C+tAu5SM9jxBseggRDzDs=;
        b=ORo9LXwp+aeT9+I5edczq8eoEv4OtxmkmjexURhmqiv0pOszeS9VJiKBFYcPFJLUF/
         uyl3isrnJ/DWKudXONDAWeQ4WOnldKug2QFNJtYjor7WuhGbWX5cApLRYZLjKOfew5SA
         iZon8RYofYindv7gNj/d+pBNkNNsq9LhCT4SiYsFJpwf1RFCB24a9u4dcv6ECRKSWLmt
         iU56JZqkWFD7Ejsfh5uz/d7moNRP5Vts0tyELxiR1KiPDcp2QrkBcV3QMcGNoTNThEqu
         F8jk0CbVk3f8tXRfsLtVL/Nvtq4iVoIY/LzxQQsEHL8gYAqviGaAaGlg5qZEKoGgUFQ0
         7Y2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id bd12si10369060plb.193.2019.02.11.10.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:19:33 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 10:19:33 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="scan'208";a="145954222"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 11 Feb 2019 10:19:33 -0800
Date: Mon, 11 Feb 2019 10:19:22 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
References: <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211180654.GB24692@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:06:54AM -0700, Jason Gunthorpe wrote:
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

I kind of like it as well, except Christopher did not answer my question:

What if user space then writes to the end of the file with a regular write?
Does that write end up at the point they truncated to or off the end of the
mmaped area (old length)?

To make this work I think it has to be the later.  And as you say the semantic
is as if another thread wrote to the file first (but in this case the other
thread is the RDMA device).

In addition I'm not sure what the overall work is for this case?

John's patches will indicate to the FS that the page is gup pinned.  But they
will not indicate longterm vs not "shorterm".  A shortterm pin could be handled
as a "real truncate".  So, are we back to needing a longterm "bit" in struct
page to indicate a longterm pin and allow the FS to perform this "virtual
write" after truncate?

Or is it safe to consider all gup pinned pages this way?

Ira


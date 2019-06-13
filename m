Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 443D6C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:45:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F04BA21721
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:45:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="V4uYx3PC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F04BA21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 797EB6B000E; Thu, 13 Jun 2019 19:45:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 747F16B0266; Thu, 13 Jun 2019 19:45:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 636CC8E0002; Thu, 13 Jun 2019 19:45:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F05F6B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:45:32 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v80so523203qkb.19
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:45:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3+t+8plqnMDu5LItEINv+R5LzGXlbnOEW8lA7KqYoSA=;
        b=baG2KuSq1BE4HppEUBd0yTfgWpYxJBlkghqxuSUd1HeYl0W9MVBdT/d6y3Wxe5EP3H
         7tGgO1aGiYX3rWt+GzghZRyGmBBe3MjH9anb6PDX7le4KBVExeZRqjmnd7ApvD4sxWVI
         mICcNXMRFV9fgfFT57Sw3vAUYb9jIUS3606xiODE+r9QSMA5jc42SiIMAnYS5P5Zbjb+
         JftwI4lTSpIZw7UAl621UPi+jSX1kuQkzQZbFi/XO3ISkIg5ZlCDNgtA8QzCCvzWVzF6
         IzFWPNiFWd24I/fmDMM1agJhArgcr0Lvuhst4LZ0YA7K5XsgveJaSYbomlKpHQgqmf+w
         4E+A==
X-Gm-Message-State: APjAAAWuDWBGeAD8XRF6T2c9dRoyqa3PWk7ZFfEnMOVA0krfPeninr84
	xmZfnygz5J9aKX9X1l4e9B5h/QhOO87qWwBzH9fzcMX11GoevRYV/FeLHMa8VtxlqJXT/YsSlAw
	aCEYOpFwHE0NcPClNxgu0SUBHrk6f3fHYY3ziwqyG0ZOFGKM1sYtaaPcV1ibag5nlVw==
X-Received: by 2002:a37:9b01:: with SMTP id d1mr69883715qke.46.1560469532029;
        Thu, 13 Jun 2019 16:45:32 -0700 (PDT)
X-Received: by 2002:a37:9b01:: with SMTP id d1mr69883671qke.46.1560469531335;
        Thu, 13 Jun 2019 16:45:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560469531; cv=none;
        d=google.com; s=arc-20160816;
        b=Eh6/Ro+MHLy5tMpK8rgE2hR0QO+aBVYBVml+1DrGOQ4GM7NCrMDA1OclWKDLVeSAm4
         jySJYWF5i+14OQn6k1V2dXWNJqJVnP2olLhaoOVA58aJgW+pHfFgj/R9jfg44H1lYzlW
         Xwdd08gWi1kNWQdF/2nI7Zdw7SyC7AMr4AeZMrmW0g5ksHu0fwqoLZshiZ2NIeMPVaFC
         /e+lHAhVNKz6h10GnuOf7OmldI0vjOfXtAxaFmoxXm9P+3Fnqxtc+5b8raLen15hjD4m
         uUf5+Xu+86e9rNVFs9nkPoTaEpEyV1+MjXQCk6EAJw5GML4hnamL8I+mSPZudhd64k2r
         N+DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3+t+8plqnMDu5LItEINv+R5LzGXlbnOEW8lA7KqYoSA=;
        b=KJr9tXUS0Dat+37mhB3ZDnHF8XPjmd0sJj7YCCSWl6d6m/0Pvdq8Ey3yl982rf7JXd
         LP+4qjLxpPdQINtTs+7TEEauOTG9kJfrruS6ylGWoglqXarlE0NPN5P7xIV0R9qGDGYq
         d7+cEqZ9FITlj8v0ob4QhSDKDjXAWIhx1CkWh+TyAVbjpqBWAPNOfxPAobGSQ1M/Gd3C
         zCaaoxbk6pFGXdVAyIsUCZvigr7c/Cs3bjWwovQDKxW5fzSLHEzs6pH+zCFTmIkv5+SX
         V8JLL6wkUshlb9yV0wkpi52Rr0ptPULElO6QJfU0RkL5TFPKZZIm8fVKr9iwUhb+5Wrb
         wj4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=V4uYx3PC;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s14sor2233751qta.47.2019.06.13.16.45.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 16:45:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=V4uYx3PC;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3+t+8plqnMDu5LItEINv+R5LzGXlbnOEW8lA7KqYoSA=;
        b=V4uYx3PC9/Kgy2M4ZekgvRKvGqR7t7tO5empinBcdD/vjjrTDNXNvOpJr4/tQqqwEv
         pgwxcXIhwGK63QcFR+H2l9DHorWqNbCBtL/l6TDJJHIPYNsX9L9ltGsrgYOW3djbfTBk
         +CXWBZJDK9oBlsTLuRXbHuNYYhdEA1G3FVTmNkzNArpZNxg9Y+HQQ0VSyzjYgYXSbRs9
         dsl1IHcwMZEtpAJdgQWfZ90e/nLGeyYk/+rPuZQscIiBjl8tNgkwswTbzSy2Qj7AjBEY
         8qq4PDFRq3uqJPA6SKTJGsY5tJs7i3mv34NRvdlqzlDhrOcr5qUMSiJ4ZEoA8UNdsYha
         GrlA==
X-Google-Smtp-Source: APXvYqyYGz8y4mU0RR/vAVXwfFNX88unrTDt/8bHx6WUKQJx5OGFlsQT6pP8kmmk4D4YyMl9wIuX5A==
X-Received: by 2002:ac8:2f7b:: with SMTP id k56mr66798515qta.376.1560469531072;
        Thu, 13 Jun 2019 16:45:31 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id o6sm757625qtc.47.2019.06.13.16.45.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 16:45:30 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbZPO-00019B-4b; Thu, 13 Jun 2019 20:45:30 -0300
Date: Thu, 13 Jun 2019 20:45:30 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190613234530.GK22901@ziepe.ca>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
 <20190613152755.GI32656@bombadil.infradead.org>
 <20190613211321.GC32404@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613211321.GC32404@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 02:13:21PM -0700, Ira Weiny wrote:
> On Thu, Jun 13, 2019 at 08:27:55AM -0700, Matthew Wilcox wrote:
> > On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> > > e.g. Process A has an exclusive layout lease on file F. It does an
> > > IO to file F. The filesystem IO path checks that Process A owns the
> > > lease on the file and so skips straight through layout breaking
> > > because it owns the lease and is allowed to modify the layout. It
> > > then takes the inode metadata locks to allocate new space and write
> > > new data.
> > > 
> > > Process B now tries to write to file F. The FS checks whether
> > > Process B owns a layout lease on file F. It doesn't, so then it
> > > tries to break the layout lease so the IO can proceed. The layout
> > > breaking code sees that process A has an exclusive layout lease
> > > granted, and so returns -ETXTBSY to process B - it is not allowed to
> > > break the lease and so the IO fails with -ETXTBSY.
> > 
> > This description doesn't match the behaviour that RDMA wants either.
> > Even if Process A has a lease on the file, an IO from Process A which
> > results in blocks being freed from the file is going to result in the
> > RDMA device being able to write to blocks which are now freed (and
> > potentially reallocated to another file).
> 
> I don't understand why this would not work for RDMA?  As long as the layout
> does not change the page pins can remain in place.

Because process A had a layout lease (and presumably a MR) and the
layout was still modified in way that invalidates the RDMA MR.

Jason


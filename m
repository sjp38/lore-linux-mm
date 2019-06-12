Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84B2BC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:12:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DBC720896
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:12:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DBC720896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9B426B000D; Wed, 12 Jun 2019 18:12:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4C066B000E; Wed, 12 Jun 2019 18:12:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C61706B0010; Wed, 12 Jun 2019 18:12:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3476B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:12:18 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y7so12987919pfy.9
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:12:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fXhpA9s4sbPwy7PieHEbsTSpUAfu3+51EOQG/7tCsfI=;
        b=JvCfIYRaf0MV+LOCrqKhiD0b+qZ9Ycxc0udnQVhd9cMmQ6sEDPtl5jSAf2wA2z3tUO
         Ztxqzb+AuUoAYyPLwWCC2Nx74zfabc/6PUP1wIXQY8XfmkipyI1QOoKlaoBRZT6BRuyY
         YbYfio9QLtyUaevHEDQRuOucdIGOU2KpOA6hrY1Dy7tMtzAM9OosgtHqWBt02hPyYWcu
         uHIe423/LD8Nl0sMF68n80aIHtuVFG/awNsd+Jh2Sm5rxP1axa5eoGsVCIlA27BPUJde
         FtyUAyvT/obVGyjuRWHGz4nAJCYeiH5kv2EEUWC8se1zMmVea9Rn/vy+PKh6ikTKcbtA
         fFCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU/hz9EKnV9dEg8CevDyxxrAq0FJY8S/Nln7Aj77oY+QgGd3TPx
	Uniry0zp6D4Bqy6Ago6YHvyLVcUvKTuI4KBQl2OFtaY+4MduYSmxww+vK41qpsi1wzDzOhjP+Br
	pToH5e/hNXTNxpIbqD0tf0g8AcsEfiBbnWijYOqdgRgbfCU21Pqp3le3U2OtjaiYsPA==
X-Received: by 2002:a63:5207:: with SMTP id g7mr26237324pgb.356.1560377538164;
        Wed, 12 Jun 2019 15:12:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4LbcCSEu0Yze8IdhPk5+tfUphndAjK19TPOrfwoEWOpVFH3FgMrahd7MD+G7eBEsczl3v
X-Received: by 2002:a63:5207:: with SMTP id g7mr26237284pgb.356.1560377537296;
        Wed, 12 Jun 2019 15:12:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560377537; cv=none;
        d=google.com; s=arc-20160816;
        b=o6MawR9cfJR06VGUZiCajrl3piW/49ecIJMabWVv4d0v0yT5glqQOC5fv9WHn1A39p
         leTlv38/nfDbC5TREdnYRUbWULmchmgsmcX0ja8He2Kenq4gmSuFjDkK1rWxXTGjX4Qx
         4s1JQqRMs+9Zda9hj1MVwQ9Ig73MAZMKqR67tu9xJqgSziQuX55ILz78MxO/V8O0XW/l
         m6DfrnSWwZbXGa4iMDbuH0Bn6BNClAkDIXTlgxdRALmMBNL0pk0sniE26Nrr8AEpLiiq
         g60RX8GeN7FhsMxUmx3okorsxte+vkn+L1AZkU/YHMdz9iygcS9ZQQbGCgyMjMHWBPFS
         WY8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fXhpA9s4sbPwy7PieHEbsTSpUAfu3+51EOQG/7tCsfI=;
        b=XZJxGKYbZzLPV81nEmiMYGDkzvRwA3fzlhNqVbHkYxlOcLKYfXtDgcSKU1++4DjpRu
         gB7xqOf0VRy85df1r/e4DvhqwRu8I50vHaLzCuERVpMio7U+g0OxfvIKwkUTV7A/LIBG
         wN1kqSRUrrW73FmdSdVI2yMOChB7a78sOrH98HaMo4x3VJRz4UsGXB5nxLZ/SPffO29F
         d3v5Gu2ln4Kk5ApQDfvB/T/H8GlauJEZLKRrmIq7V8q3Dny7eTozaE6FuEf7evWb94y/
         WgL1mlIMDc2wzJUFWQcMYsKWi5VF3ZfogsTPYVHpuHwqkZ/Q235MI4leHAZeHLKFgab9
         kihQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a33si749565plc.283.2019.06.12.15.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 15:12:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jun 2019 15:12:16 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga004.jf.intel.com with ESMTP; 12 Jun 2019 15:12:16 -0700
Date: Wed, 12 Jun 2019 15:13:36 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
References: <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca>
 <20190612120907.GC14578@quack2.suse.cz>
 <20190612191421.GM3876@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612191421.GM3876@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 04:14:21PM -0300, Jason Gunthorpe wrote:
> On Wed, Jun 12, 2019 at 02:09:07PM +0200, Jan Kara wrote:
> > On Wed 12-06-19 08:47:21, Jason Gunthorpe wrote:
> > > On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:
> > > 
> > > > > > The main objection to the current ODP & DAX solution is that very
> > > > > > little HW can actually implement it, having the alternative still
> > > > > > require HW support doesn't seem like progress.
> > > > > > 
> > > > > > I think we will eventually start seein some HW be able to do this
> > > > > > invalidation, but it won't be universal, and I'd rather leave it
> > > > > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > > > > on fire, I need to unplug it).
> > > > > 
> > > > > Agreed.  I think software wise there is not much some of the devices can do
> > > > > with such an "invalidate".
> > > > 
> > > > So out of curiosity: What does RDMA driver do when userspace just closes
> > > > the file pointing to RDMA object? It has to handle that somehow by aborting
> > > > everything that's going on... And I wanted similar behavior here.
> > > 
> > > It aborts *everything* connected to that file descriptor. Destroying
> > > everything avoids creating inconsistencies that destroying a subset
> > > would create.
> > > 
> > > What has been talked about for lease break is not destroying anything
> > > but very selectively saying that one memory region linked to the GUP
> > > is no longer functional.
> > 
> > OK, so what I had in mind was that if RDMA app doesn't play by the rules
> > and closes the file with existing pins (and thus layout lease) we would
> > force it to abort everything. Yes, it is disruptive but then the app didn't
> > obey the rule that it has to maintain file lease while holding pins. Thus
> > such situation should never happen unless the app is malicious / buggy.
> 
> We do have the infrastructure to completely revoke the entire
> *content* of a FD (this is called device disassociate). It is
> basically close without the app doing close. But again it only works
> with some drivers. However, this is more likely something a driver
> could support without a HW change though.
> 
> It is quite destructive as it forcibly kills everything RDMA related
> the process(es) are doing, but it is less violent than SIGKILL, and
> there is perhaps a way for the app to recover from this, if it is
> coded for it.

I don't think many are...  I think most would effectively be "killed" if this
happened to them.

> 
> My preference would be to avoid this scenario, but if it is really
> necessary, we could probably build it with some work.
> 
> The only case we use it today is forced HW hot unplug, so it is rarely
> used and only for an 'emergency' like use case.

I'd really like to avoid this as well.  I think it will be very confusing for
RDMA apps to have their context suddenly be invalid.  I think if we have a way
for admins to ID who is pinning a file the admin can take more appropriate
action on those processes.   Up to and including killing the process.

Ira


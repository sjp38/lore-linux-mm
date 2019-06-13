Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFF47C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:29:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78F712082C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:29:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="ez3y4b43"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78F712082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16BA96B0006; Thu, 13 Jun 2019 11:29:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 142046B0008; Thu, 13 Jun 2019 11:29:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 058E46B000C; Thu, 13 Jun 2019 11:29:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAA146B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:29:55 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id i196so16931868qke.20
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:29:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zI+cml8WbrmbJ9toyFXRrApWdKeWP1klnItjSAKRPGg=;
        b=l66+vKLCfAqTALClKqcTH1xongthk8DnR0ZME87HYrlYWrM0jnZDlI48/l9LKIqDx8
         GyrpqFngFhyNywPanFoeyRu07dN+tQKXxVN/pecfUDeOJUFVNBcPIprLEcyVLYuUXBk2
         jXSsPC4kILqDsT5oNjAdC6eqdMxDp7LsWCGagC9mlqVIzTcamGzQEGxqgryICd+sxoqQ
         c222aataDEZrqqw7IWYeXVf/vrM+yoDGTuaaDffBvsiixwEIbVPGiXZv0PVJL9LLqWIC
         pKiVUQJjsbGeouSJtrjUWpcdlHr0h6wsVv3NmPtB2XtPkUGo9HInJ2XmAX5XXCwsqDcj
         IDUg==
X-Gm-Message-State: APjAAAUxwsL0eZ02lB1j4gHoU9AISbLmTdRLwYsFww8tkife2eVmmRbI
	C6kBzLKDPdGGRgcBX0qqhvcHlYnjChV/z7UWuOm6Zvz8XPUpNcGU8kAmHlH7/1CeAuQdc0EDkff
	B9H6EsXqSYhMHlseKgzESPF9J/k+AZnDPhRC4kR3oLyD/BQtYrn1hnyhrzmEwTd7wVA==
X-Received: by 2002:ac8:26c8:: with SMTP id 8mr19265685qtp.308.1560439795633;
        Thu, 13 Jun 2019 08:29:55 -0700 (PDT)
X-Received: by 2002:ac8:26c8:: with SMTP id 8mr19265642qtp.308.1560439795056;
        Thu, 13 Jun 2019 08:29:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560439795; cv=none;
        d=google.com; s=arc-20160816;
        b=P2gv2GhU1xZbC6l11Zk0SsAdipx1bYCPjQ1bZxVWA+MGOUvs9/hQU3jDtTS1i9Srp2
         vhQu648VMlgdtrepNfkQ8yFRgCOJOHhnP/UloTUZrRJ96wjYoa7iPKoKXq54Th4MQtuH
         hIK4YZcDk42gTyha17VczM2Gy0Sl/DGQP53soIKeqrjo/eXeXRaj0Oq6paxWVMyHid38
         ST1Wu526z9QgIs+xya+7R+pEkegL/S/4dz38aNOElY1CQ7XqeIUuv6NYHrlp0qojKgsI
         Je4xYuf/WZa7Ms+kbo3LOmu44dfghWgT/bDnXXfAU5nnHuBK1ZP26QAiFcnI6c8wMTvL
         A/Ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zI+cml8WbrmbJ9toyFXRrApWdKeWP1klnItjSAKRPGg=;
        b=0lUPIq4mPdWXJMX1jXZTb7mV3iSY6beQmX80tITJxKvaf5StMqq6KFsZDqHQxXbqHo
         bHU2ah91YGENHtLH/sYKT/RVDGBmCBp0qzeuZWmPuyyz0MMnEPTrJJC1idU2yi26Res1
         tdrJPRu80Dz53oOQr0iwC3MAhcofddVF+0WPKb/C3yzOzzHhc4qgLznq016y2VcVn5vU
         LCpYvK7EyPKYjaREm5pFqulIor34NcLlM11L2Z1ueYVf69WM+KyMgG15woreIOOpyp+b
         jx1s3aBsP6stQ129DYvLdxzs6bat9pUm8ydpFU+8CxOwp7ZK0LvQOuldGWIRaRW0J+nn
         r7WA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ez3y4b43;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w1sor2170536qvf.73.2019.06.13.08.29.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 08:29:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ez3y4b43;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zI+cml8WbrmbJ9toyFXRrApWdKeWP1klnItjSAKRPGg=;
        b=ez3y4b43vsN45W2H2bDstmo6Om2wBZpYtJKgMMjQ9NBoecm8EqzxMc/rNSpmMUBedy
         80Ex/NCrVk0GjamXc8tFY6oZxMeqGSAa2XxliMKTTtJWm/Hdv+7/O2TlnSRLVmYLMjc1
         8QLaCJlqlQNIG4Wtw5O1fja9ybK4S3vwEG6x4PLpKGnKhfBKyUDjUSuJ7Daf2FmV0ukB
         Fiy/FGLk6V0O5Od1WI6hEe1YQb2rKTshssT0ZDeknDIfsjbY9xOSOCaaERP1VJPOdnB9
         Me1HNUVA3ivb0wrw4Jz0PdvTbXzAgXVoN/LwODHkV6bcRV7ByakROGDgfhqlpDrkzCce
         zwyA==
X-Google-Smtp-Source: APXvYqxumou76h8DgPuXHGACUFtVz1bj3RAtdr2UUPeKh8lpCv3ZK4QnjNs+8s/8x74HDjzAfBeu7Q==
X-Received: by 2002:a0c:b163:: with SMTP id r32mr4246320qvc.169.1560439794791;
        Thu, 13 Jun 2019 08:29:54 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s66sm1645906qkh.17.2019.06.13.08.29.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 08:29:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbRfl-0001zA-RQ; Thu, 13 Jun 2019 12:29:53 -0300
Date: Thu, 13 Jun 2019 12:29:53 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190613152953.GD22901@ziepe.ca>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
 <20190613032320.GG32656@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613032320.GG32656@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 08:23:20PM -0700, Matthew Wilcox wrote:
> On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> > On Wed, Jun 12, 2019 at 05:37:53AM -0700, Matthew Wilcox wrote:
> > > That's rather different from the normal meaning of 'exclusive' in the
> > > context of locks, which is "only one user can have access to this at
> > > a time".
> > 
> > Layout leases are not locks, they are a user access policy object.
> > It is the process/fd which holds the lease and it's the process/fd
> > that is granted exclusive access.  This is exactly the same semantic
> > as O_EXCL provides for granting exclusive access to a block device
> > via open(), yes?
> 
> This isn't my understanding of how RDMA wants this to work, so we should
> probably clear that up before we get too far down deciding what name to
> give it.
> 
> For the RDMA usage case, it is entirely possible that both process A
> and process B which don't know about each other want to perform RDMA to
> file F.  So there will be two layout leases active on this file at the
> same time.  It's fine for IOs to simultaneously be active to both leases.
> But if the filesystem wants to move blocks around, it has to break
> both leases.
> 
> If Process C tries to do a write to file F without a lease, there's no
> problem, unless a side-effect of the write would be to change the block
> mapping, in which case either the leases must break first, or the write
> must be denied.
> 
> Jason, please correct me if I've misunderstood the RDMA needs here.

Yes, I think you've captured it

Based on Dave's remarks how frequently a filesystem needs to break the
lease will determine if it is usuable to be combined with RDMA or
not...

Jason


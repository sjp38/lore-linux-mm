Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F995C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:05:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B44120665
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:05:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="HSw6uNWb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B44120665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB7B76B0003; Tue, 18 Jun 2019 09:05:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B687A8E0005; Tue, 18 Jun 2019 09:05:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A56248E0001; Tue, 18 Jun 2019 09:05:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83CDA6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:05:46 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x17so1096377qkf.14
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 06:05:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TTs4qX/AlYeTgBhCVY6oKlnamVeM1+PLnw1E3BGPQ7k=;
        b=N/da8gg8yuRyU0/mxDH3KcEetU6kGSMGxnhxKAqhOicMiIgTw+jWrWV2AIbAJl5NbI
         yGcv/DfNUuhEdcDRcDGP6jRSoFWg03jqs67tpKYgb2CVv+WUTKXDQOA+EyeeqhzkUETi
         q//EdJWiq6fN7sSHJlm9bnanjwge5NS8pzWeGPRdrLZIq35U0xsqvqu5/s8oqO4E2Sa8
         xzbCWGdx/gBBePY9yDXhD9d6vTFp6L8A8NXqe7TodLtrvZ3BC7nMOzRmzgONqDR0jVNj
         vIYykS0gVYjPqfVEm2pIYku/SP79CCXEs+meiCXCHYg8uvDZJ+lVxWqdmpnTZjSZ924I
         5zCA==
X-Gm-Message-State: APjAAAWDotgJuqpYLODBNWRd1ak3XBPoAQgSSNEhjpBBp8y6NE5j+hA7
	DtgTAH417Nqh4zhoFCQLgRQUMKImoEcO2sjlOukQLs5BIcfFFnEZPHw6igNo3rl/0c1lMY//Rz0
	U48Ft682C8iXUo0Bh3WyXSiuLy6sxd0rOJWHvemwU9sOC86zRMwQ+g1+VnF6SmpA7SQ==
X-Received: by 2002:a0c:91ef:: with SMTP id r44mr8583670qvr.113.1560863146295;
        Tue, 18 Jun 2019 06:05:46 -0700 (PDT)
X-Received: by 2002:a0c:91ef:: with SMTP id r44mr8583615qvr.113.1560863145773;
        Tue, 18 Jun 2019 06:05:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560863145; cv=none;
        d=google.com; s=arc-20160816;
        b=y99O4zJxUzxjOAMBeF7avp9FDVtyjBOswk2Q51OxknjdutkfQV/UXog8sACDMlkcbO
         rkg15JwTPTqmrqHZHt5o2/l8UBgoN/ZcoX5PCU7W5dOX86TZdknXqBu8suyGEd7ZTm8y
         joz5d+gaRLB/2USX08X+tFi2a/JzbP481BmHgtKPuaC8eLa+CFgFPEF4AV9s0BnpS6wG
         uiFQ4UqnG1KXrM8CQ2ie0ruk99iESxXVtgkOkL1IbgiLme14pfOWnmvxLTg7/n73zxkD
         7HPfwuXymMmbzkI4AZo4USsfrky/ez8+JTe9bHp8mOMDI2Q3/pEKVXcAFIuPjBKyV/p+
         bvtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TTs4qX/AlYeTgBhCVY6oKlnamVeM1+PLnw1E3BGPQ7k=;
        b=DPK9NkSmAB64mFjkAFFgsSvgAtK21h6FsiY0wpYZbRPknVy4rmltrW+OtF/YdL0AA7
         D2naHMKmJZ3ypk+mGZ6/6nkxVl+/HhEh894W+yh7VsgRM//ZyHr0NfuHEsWS6i/APxHH
         kSF27lj0orTOzDAFni4Z1XLzSyD+DBwPOqJ1WAwzatQSV0kG6+hmlsD7Q4BVgfmE7od3
         0RGWi3ZFb2gymGrrxPEf/PwHfM5ybrCFsfnWIDvU4DhdVQPK92tLxl5DRcIsk51wI/io
         ZOxw/0cEhztg2L89rEhcONAhNEdN3k1KBzaQ6+r9DkvRPdLwRqmdiyhSlaXQfPgro5uf
         q9oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=HSw6uNWb;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a24sor9145029qkl.129.2019.06.18.06.05.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 06:05:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=HSw6uNWb;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TTs4qX/AlYeTgBhCVY6oKlnamVeM1+PLnw1E3BGPQ7k=;
        b=HSw6uNWbQt7fjJEsOb5v36NS40qEnnvUQQOjF8RYBujsDACr03g6V1BCXbU+eBSqgE
         PkA+PsoTe9P7s1R1QtqFnAPzo/EF0jJEZAr6tsjkwmr6bfdZ90QRfQscfOxkLlDOvybP
         Swzg2ZlAGssU+HOBqU4mE1v3gbJZ/njoW2LtezmgzdRWxLtbcsPt+AxODrrQQ57lBck6
         w1NOErizBGOfwHoHv6R+Rr9DtnvHuBJAl6gq8Zzn0we2Jq+p11rahAQx0yLw5X1G4Fb3
         BYHFnuVdQJ8DB5EIRKcdRgWqsSU3aocFHyuDxLPSQ6xUqP+lxAtEF+CfR+M6EBbrnn2T
         dTOQ==
X-Google-Smtp-Source: APXvYqyTVmV2qJESAaYOKHbD1BjBEsgUZPM0i2g79H7bXawYK5ERfS0qh6JfLB9C36JFGw7C3yUXcw==
X-Received: by 2002:ae9:ed0a:: with SMTP id c10mr91466247qkg.207.1560863145518;
        Tue, 18 Jun 2019 06:05:45 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id k15sm7008956qtg.22.2019.06.18.06.05.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 06:05:45 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdDo0-0002Yh-HV; Tue, 18 Jun 2019 10:05:44 -0300
Date: Tue, 18 Jun 2019 10:05:44 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 02/12] mm/hmm: Use hmm_mirror not mm as an
 argument for hmm_range_register
Message-ID: <20190618130544.GC6961@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-3-jgg@ziepe.ca>
 <20190615135906.GB17724@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190615135906.GB17724@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 06:59:06AM -0700, Christoph Hellwig wrote:
> On Thu, Jun 13, 2019 at 09:44:40PM -0300, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > Ralph observes that hmm_range_register() can only be called by a driver
> > while a mirror is registered. Make this clear in the API by passing in the
> > mirror structure as a parameter.
> > 
> > This also simplifies understanding the lifetime model for struct hmm, as
> > the hmm pointer must be valid as part of a registered mirror so all we
> > need in hmm_register_range() is a simple kref_get.
> 
> Looks good, at least an an intermediate step:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> > index f6956d78e3cb25..22a97ada108b4e 100644
> > +++ b/mm/hmm.c
> > @@ -914,13 +914,13 @@ static void hmm_pfns_clear(struct hmm_range *range,
> >   * Track updates to the CPU page table see include/linux/hmm.h
> >   */
> >  int hmm_range_register(struct hmm_range *range,
> > -		       struct mm_struct *mm,
> > +		       struct hmm_mirror *mirror,
> >  		       unsigned long start,
> >  		       unsigned long end,
> >  		       unsigned page_shift)
> >  {
> >  	unsigned long mask = ((1UL << page_shift) - 1UL);
> > -	struct hmm *hmm;
> > +	struct hmm *hmm = mirror->hmm;
> >  
> >  	range->valid = false;
> >  	range->hmm = NULL;
> > @@ -934,20 +934,15 @@ int hmm_range_register(struct hmm_range *range,
> >  	range->start = start;
> >  	range->end = end;
> 
> But while you're at it:  the calling conventions of hmm_range_register
> are still rather odd, as the staet, end and page_shift arguments are
> only used to fill out fields in the range structure passed in.  Might
> be worth cleaning up as well if we change the calling convention.

I'm thinking to tackle that as part of the mmu notififer invlock
idea.. Once the range looses the lock then we don't really need to
register it at all.

Thanks,
Jason


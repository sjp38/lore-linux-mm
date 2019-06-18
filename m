Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3100DC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:04:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC0CA2063F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:04:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="jk6is7nS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC0CA2063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CB486B0003; Tue, 18 Jun 2019 14:04:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77B8C8E0002; Tue, 18 Jun 2019 14:04:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61BD08E0001; Tue, 18 Jun 2019 14:04:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 400416B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 14:04:25 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n77so12991195qke.17
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:04:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=okyRjZf9B5dx07ohdH8HMJVvyCKHxrwwt6GBfDyhnYI=;
        b=Slu8Nn64a4xwDvGqs9YrKyBFEjzngisVzqUheLrsF1MuTC9xbfv3lbN/qDtdafCAGX
         YRKl2NZJyFFW/Lzq3yicyp98Vmr69PznO2bd75xW1Qypihi2kkd7Rwav7EaX9ktQxILg
         fIKH4HQkdR4Mb9ZMHXRjw+XXXxgaCVrHzu+Qsw5jiZjhbNmmzHivUH7CBmgDlXtbsklY
         cT+b1TwKzCpR6cs+Acp117pnB+zEQ8rel9UxuixwX7wvTMkYOqGo2Mi4Kry6ZKkrQD5g
         2lm/pl2HS4qTD7f+kYuX5ZqKcCPbViViEESISW3ScOrEYrzv4JTlcorzYrH5eM2y/eH5
         5whw==
X-Gm-Message-State: APjAAAXlI3js2IhxowiFghgVXF+ZiZGUgfkfcwydTDaObjkCBji4oStA
	oxwvkK9JRkJponaIRkja0teysl3POGsPDLU75td3vQkDRWEsfmkmWTH0vnpyZSSXSM/RBZIFFsY
	IpnyW+QOE9++MoWqT8pNHTgVtaDkHjczqQ5R4D8Vedlk5f4q8SUeng//yDGwqPuvSIA==
X-Received: by 2002:ac8:2f66:: with SMTP id k35mr45496492qta.174.1560881065042;
        Tue, 18 Jun 2019 11:04:25 -0700 (PDT)
X-Received: by 2002:ac8:2f66:: with SMTP id k35mr45496426qta.174.1560881064288;
        Tue, 18 Jun 2019 11:04:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560881064; cv=none;
        d=google.com; s=arc-20160816;
        b=oLwSreqi1TtdnBkb8i/16V23J4aH3r8b/cfSLD7/VVkjiSdm7318Ke269sBHX+s5ZG
         f7AkxbrhY+tpDn/dGNOtbUqN0ITKFNxbqn9C0kMUVTauZUHNPME/A1glCAoiRrILxSrG
         br/1rUuiSTeqjblFLUdj5CED49skziEwES+nz51ybAEddQXiShssa4jFt1Iku9edfdSl
         yuRHtQT6xx+vw2/osuTWiI57JENuxYZKFwf+B8t2HXR/8VrxRqKGrUhf0E0vPAX9zApr
         3MdH06DOB3pj81qXg1Vq53nzjUtx7zaTpxZfGBHUDheu3xKgZEWEyjvP3Jb3xod0Ss+z
         l+bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=okyRjZf9B5dx07ohdH8HMJVvyCKHxrwwt6GBfDyhnYI=;
        b=AUCKvFueueaF2IstJIkOpaSn5efd86hBqtLHyaNdPn6630Sw5ln/Y04Qh3C6jiv0X4
         h0VKbZwUg4Scaaz+u3A4Ix8JdBUK/RmYVTHnDA7oEH1vThq/g5I5h3Q3XoC6qLOftUOF
         aX9ILPoRRjo84Pu2reHvoldbN7Jb3S/GfXPsNhH2oDKJl5fkU6gHNDHGCs+ew/xgsZ1k
         tc5ZwD/NzRFN874sXYaLsKWvK+HFijsByyBz2TA9JjKl/24ayztL1AFqluXBHpZ+mnV7
         rYSbon+YabJpbfN7YCOKSZQ/HByEoSy//kLPS/hHRvvVq5MfDM4ZXyYWVBXg32w3Y2a3
         lxqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=jk6is7nS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c24sor9988296qko.8.2019.06.18.11.04.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 11:04:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=jk6is7nS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=okyRjZf9B5dx07ohdH8HMJVvyCKHxrwwt6GBfDyhnYI=;
        b=jk6is7nSmkWA4Mc6UVjL/PYCTdkXKQ2ikA9XsaXq/PVjcroLlHZkg7ij4JP4DcORqH
         mz8lBKypK4EhTBlTjipdOVoZzqs0gooV5BD71kqo+EzYxmAiZwcr3ZQj3Jc5ivJVFMB3
         SRH/D9/kqYfRYwCCtFBsV7hlq6/6O+dR1xHwPPtPvVT+3sHCHfJTkoXL6OJ7Nqg43IOp
         f3/QmIYWWGqf0baTFPWhHh7bvk25F0pqfrvx58LZl/dY4EtGWcfVbqRSn7iaWy2yh6Ru
         MY2y2SfyB7BxsCkTQT3M4PYdMaeNVflw3viT0XZ7VJ1d216JuQ8nS/UHNPCLcOBws+l9
         inpg==
X-Google-Smtp-Source: APXvYqxWj2mDmFVY7ZvaCukxL5n3PqpZ3GEOoAN38QvZ41wgpTgMsHaVHbX3mqFkOs2ObrlkBJP2FA==
X-Received: by 2002:a37:aa0d:: with SMTP id t13mr94831459qke.167.1560881063938;
        Tue, 18 Jun 2019 11:04:23 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id v9sm7988792qti.60.2019.06.18.11.04.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 11:04:23 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdIT0-0003OU-LC; Tue, 18 Jun 2019 15:04:22 -0300
Date: Tue, 18 Jun 2019 15:04:22 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 09/12] mm/hmm: Poison hmm_range during unregister
Message-ID: <20190618180422.GK6961@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-10-jgg@ziepe.ca>
 <20190615141726.GI17724@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190615141726.GI17724@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 07:17:26AM -0700, Christoph Hellwig wrote:
> > -	/* Sanity check this really should not happen. */
> > -	if (hmm == NULL || range->end <= range->start)
> > -		return;
> > -
> >  	mutex_lock(&hmm->lock);
> >  	list_del_rcu(&range->list);
> >  	mutex_unlock(&hmm->lock);
> >  
> >  	/* Drop reference taken by hmm_range_register() */
> > -	range->valid = false;
> >  	mmput(hmm->mm);
> >  	hmm_put(hmm);
> > -	range->hmm = NULL;
> > +
> > +	/*
> > +	 * The range is now invalid and the ref on the hmm is dropped, so
> > +         * poison the pointer.  Leave other fields in place, for the caller's
> > +         * use.
> > +         */
> > +	range->valid = false;
> > +	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
> 
> Formatting seems to be messed up.  But again I don't see the value
> in the poisoning, just let normal linked list debugging do its work.
> The other cleanups looks fine to me.

tabs vs spaces, I fixed it. This one is more murky than the other - it
is to prevent the caller from using any of the range APIs after the
range is unregistered, but we could also safely use NULL here, I
think.

Jason


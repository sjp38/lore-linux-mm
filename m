Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A148C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:38:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5132F20663
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:38:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="gEMe8OGD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5132F20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED15B8E0006; Mon, 17 Jun 2019 20:38:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA98B8E0005; Mon, 17 Jun 2019 20:38:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D710D8E0006; Mon, 17 Jun 2019 20:38:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB39A8E0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:38:09 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g30so10881263qtm.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:38:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EFgy84qSqdB63j+sw5RQb8FlQ7olTwYiiqpzSjRkr8U=;
        b=kIR1qqjtZ6fZSvsXCVkQsX3UxRmhMtLL7V6ZQmWfias/6BEpye1AB9CdSpnP10UbkW
         xGDVL7rou+8ww9Vu5rJCPLUOSfN0b+FmskZDtC5oa8lOrAyK74+2sNnkqhHQcnWmwo/4
         HzvLi8KAhSfbC2lCj3mULqrOjPM/r8OW9GsSxLn8ktcYzgueZDyhdHqU3hQsYh6Huwrx
         y3Ounc36o/T15FszzZUo7f8OkZQ7VUX9wJQKdpjRFzZA3NbwpsV2llTvIG6+T+TfbIYy
         EJLp4BW+xARH2V+WE+U8jZpDJ+E7aZnYoLb/AwI7L0SnzwGoxP2Ygw6yek136sa4MDkg
         Dwuw==
X-Gm-Message-State: APjAAAUXR/22XtHpHYeTbeZ4isJEjG7scM/SPuJEIZ9CE7sMB2ZwxST5
	DPKWDjaXDMlpMTIF5iOHs9mhjWqi7c5w5D3kTbp6KRTU2p+Dda79tQV/w4Zy9BJxg8Zsem8OOmM
	TwJPJdbky04is19SfZ4WhXE9GiGUTNTj7n5okotYDI65n5Nm26CyaEeZqOc+fTsS0Og==
X-Received: by 2002:a0c:888a:: with SMTP id 10mr25003361qvn.0.1560818289532;
        Mon, 17 Jun 2019 17:38:09 -0700 (PDT)
X-Received: by 2002:a0c:888a:: with SMTP id 10mr25003345qvn.0.1560818289085;
        Mon, 17 Jun 2019 17:38:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560818289; cv=none;
        d=google.com; s=arc-20160816;
        b=Va3DeGUZ3YlRU9Ji4WNTaJLoTMFMFH/a74wr28PpoZkctcrvdlNc1SPcf+uDEkFLx4
         sxbsxxChsFlRS/XZNPNjYGNVpEODHBNlnB6pZkPhRWk/f5fKKOKGxCVxmIunROeAubZh
         JRLw+B8u7bINAjfnybiMgzmqnqbmZCtVriFK7SDv2GPph9sumyLk8bPDFIDgULby3C3O
         96MCU/NlD0R/Bh9LzGZ59tAXYcsbLg0fNl/rFnhdKtFhSzm//HA3yM1rr+TyyKObr3kf
         B3GMc4beeqYPLm/oyPUx7Z66YcLyOef1vXjw29IwfcJtg0efydZkfDphvQaoOlGhHhml
         ePgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EFgy84qSqdB63j+sw5RQb8FlQ7olTwYiiqpzSjRkr8U=;
        b=msdGa4GK0P2crWEiNO0XuRLDDka/IEXH0NSfKhYc1OOCur+I4hyjm0gcGrgw3pwVoF
         BeqsuckYBGw3YFCZ0o2u5S9/FmhchqWSLpJUnbiU6b+YrC7skd5LvAMaPooR7//5J7+G
         uRjMS9ZE0BG0X3+KWlSWM5UOQV5w60DfFgOUgWEjHzBGb08z+rzAshPwU1ea2ZBZh/oK
         ihKm8ejXw6p6geoc1LdG/6UxyqjdsJcC46iUVK5jRmApjuNdGvlvp+eWZitiX7O83DKb
         FRjRRkn3jf9O1PITALdqCNRGxd3vd8uoho0aSXLThKgHrm1VPzDT29RmbmaJ2aOkDLAh
         Fw4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=gEMe8OGD;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u68sor8390696qkh.5.2019.06.17.17.38.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 17:38:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=gEMe8OGD;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=EFgy84qSqdB63j+sw5RQb8FlQ7olTwYiiqpzSjRkr8U=;
        b=gEMe8OGDFmOz6H46yGNGMqF8pI5BwGDEcf+SCaHqb0Q7uRwuonwPVlWfdaht7QofIf
         YtRgnZv2e9ADohWcFTRVNBYXno1F4xdqwANh3AoWhgQMpkk6q4C73j++QLk+F6iC/Wju
         IPMl2CiAFZSvU7ydMedZlrsuuDZ/6Y0XEeYIDVixBngY8FE0gVLsWnlEJSLgpw6skcr+
         zzYgJ2BJQj3dg2qGcz6M9TsKsHpszq25fWMd1XzmqaGMWCdE4XNQHbUtNhiHChs/I842
         xkYSo0wFMFiReic1CZqd6S3jyFJPcJgNcxDLbu/6GrsVfkHd0kWkCTx4jW2kP6BEEWBL
         gN8A==
X-Google-Smtp-Source: APXvYqyeFBKaRlaV7l7eUdOweeWB83eOAxMhqF5BFWtungKZNloqqlhd+ctR1JGUO5HBcVp4eWezCA==
X-Received: by 2002:a37:4793:: with SMTP id u141mr66063884qka.355.1560818288855;
        Mon, 17 Jun 2019 17:38:08 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i22sm7653833qti.30.2019.06.17.17.38.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jun 2019 17:38:08 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hd28V-0000kY-Jn; Mon, 17 Jun 2019 21:38:07 -0300
Date: Mon, 17 Jun 2019 21:38:07 -0300
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
	Ira Weiny <iweiny@intel.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 10/12] mm/hmm: Do not use list*_rcu() for
 hmm->ranges
Message-ID: <20190618003807.GD30762@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-11-jgg@ziepe.ca>
 <20190615141826.GJ17724@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190615141826.GJ17724@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 07:18:26AM -0700, Christoph Hellwig wrote:
> On Thu, Jun 13, 2019 at 09:44:48PM -0300, Jason Gunthorpe wrote:
> >  	range->hmm = hmm;
> >  	kref_get(&hmm->kref);
> > -	list_add_rcu(&range->list, &hmm->ranges);
> > +	list_add(&range->list, &hmm->ranges);
> >  
> >  	/*
> >  	 * If there are any concurrent notifiers we have to wait for them for
> > @@ -934,7 +934,7 @@ void hmm_range_unregister(struct hmm_range *range)
> >  	struct hmm *hmm = range->hmm;
> >  
> >  	mutex_lock(&hmm->lock);
> > -	list_del_rcu(&range->list);
> > +	list_del(&range->list);
> >  	mutex_unlock(&hmm->lock);
> 
> Looks fine:
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Btw, is there any reason new ranges are added to the front and not the
> tail of the list?

Couldn't find one. I think order on this list doesn't matter.

Jason


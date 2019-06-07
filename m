Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C0D9C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:47:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32F012089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:47:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="ABb2mR+Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32F012089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1CEE6B000C; Fri,  7 Jun 2019 08:47:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CD7D6B000E; Fri,  7 Jun 2019 08:47:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E1AD6B0266; Fri,  7 Jun 2019 08:47:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1466B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 08:47:38 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so1747163qtb.5
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 05:47:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=+c/gka4YIKdP7GQGtlyknCKyAsbIyrfj7eQnoWT0OTY=;
        b=EUqn30sUhwPb+e27ww7mjZbKebeqG0dUo4ORE9igT7oCkL4u7yozfhIcIRsilzYjiJ
         jgVRVywyK401Owxn7qLo3SJ+jRqEKi4EUPfaU8CpYQdZV6f2K+qRYnDMN4Tk1+R6bBON
         7egSNkMubMvE0rjy3O9pWbANJw9ztgbk9HIPAbfuHhdUA3xY1IJB1MZN9Dq8BCZw3QTc
         udiZWFyTOcKYiK+t8ATHguaCm4Eey4PfWNXYelmSrfry6NYSq5dYv42FQRX75aL5HQU3
         6UV8aaEuTKRfAhiPyO/3pGhnSPgqYJ2WEufAfXPYY6wN5+UCw6emnm3XlMJDcg8Wi4VU
         RDPw==
X-Gm-Message-State: APjAAAXCFtIelyCDfYWSriCWtXbE7G18RnHSwlcVnJMbPj3i4QPgTEXf
	w9L97gOnv1N31c7l9q4dSRekUmgqqdBTus2e8bLwZIJ3iBB1MXdv/L28lM592CV3VAM0eNMcQZp
	dKLC1bKbPo3qTsEojUdi8Ek+8mWK5Xv2x4Zx4nn4XRIyZQeWSnWi4kHtClWFdPdUkmg==
X-Received: by 2002:a0c:b89a:: with SMTP id y26mr43907058qvf.47.1559911658183;
        Fri, 07 Jun 2019 05:47:38 -0700 (PDT)
X-Received: by 2002:a0c:b89a:: with SMTP id y26mr43907023qvf.47.1559911657580;
        Fri, 07 Jun 2019 05:47:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559911657; cv=none;
        d=google.com; s=arc-20160816;
        b=dDxVO8lPEKJMWanaq3cN/sKK3R4YH4gVsWdfJ3cV8GeVHyyaIlrFptAyZwhpTXaL/s
         STPgTb9c88Dw80SlhLa6NHNb6Vj1BgMFKctphSawk0m6IRRRM6bikGVvVyrKbT03v0zK
         0zh+z1nzk7LcEweQNPeaoBaBpa19PVQ7LaZGpq3J6SWx59t9KTTsfnz14LUPa/d9MY6Q
         DfqNJKQoQQNmi3tZK6+YaTl8ToAZcU6OU16ut2yf0K3fxmb43zEDG/iPC21mfqR1l62q
         AvVW9XoyvIjBzXR0aNlgsoAx/o2azy047zeqiQsdK8/I9ugK4LuWKUObhO31MQO7fXMy
         XKZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=+c/gka4YIKdP7GQGtlyknCKyAsbIyrfj7eQnoWT0OTY=;
        b=ZcM2JVKEv3sxP3Fh030TmEC8nXPPgpH6bLyChCqO33nlsCxZrWRketpES5rC5Zm/JP
         XjhD4eFlZksXhWISBhOBBQpvjZ00d1nJTiqDtzn9XBffdXtnFBolgR1C2y7CBGdzp4aC
         XPRULLn5YHUlH+twmZQ1azqmFFw/OqTaL1l2+2Gyrvz/BKeWKWP4BKaUXb3UBLjzdg+o
         WKGWoKIJXyekBlvwmViRTMVVDyHoeTibBitvFg1U9TJvJqY9FOdxQTm9K1Na7dBFhZho
         ipvYJVgQwm3CNkhV29bfr3fsY5dpVrOMMfQw7l75q6iK+euxDBwSGayZSF6COvrJG3Qg
         9/PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ABb2mR+Z;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i38sor1658727qvd.21.2019.06.07.05.47.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 05:47:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ABb2mR+Z;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=+c/gka4YIKdP7GQGtlyknCKyAsbIyrfj7eQnoWT0OTY=;
        b=ABb2mR+ZZAV64KjuG42+1j8wOiBv07RLnEhokivS6dkelGWvCuHxWLWQ38ajecNiKk
         I8sax2ddk0PeIAqNVoPFLfW2P6rXeC8U5w0Jrec9nBiBmucTap3T5/jsCXs4CCfSOwLl
         wfrdji6NUMTVsPnvyFNCJydZIcD7xJBJqy9vaUBkvmih1nK7k6E1uAvGVfIjlPupPNSe
         ifmSWCefglCgnsrpSVAbfkmbRRGkaFRHLdx9xyHbg7k7w/Yl+a3pAxaxNVqe/daJJP19
         rIUhjtOhW2yxF3FTfuEmH7csLa2KcjCRb/9e1fXaLpf1XmSt14O0WkYFjloyewXGofh1
         PWFg==
X-Google-Smtp-Source: APXvYqwdM/GqmL5RLvNREoHCt3f9E4ZMzm0f8oQsiHff8vd5bIxBZ1U6i5LCEvmvIuO+Xy7+sKWVmA==
X-Received: by 2002:a0c:d610:: with SMTP id c16mr44488711qvj.22.1559911657239;
        Fri, 07 Jun 2019 05:47:37 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id t8sm1271201qtc.80.2019.06.07.05.47.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 05:47:36 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZEHQ-0007Fq-EM; Fri, 07 Jun 2019 09:47:36 -0300
Date: Fri, 7 Jun 2019 09:47:36 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 05/11] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
Message-ID: <20190607124736.GD14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
 <86962e22-88b1-c1bf-d704-d5a5053fa100@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <86962e22-88b1-c1bf-d704-d5a5053fa100@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 08:06:52PM -0700, John Hubbard wrote:
> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > The wait_event_timeout macro already tests the condition as its first
> > action, so there is no reason to open code another version of this, all
> > that does is skip the might_sleep() debugging in common cases, which is
> > not helpful.
> > 
> > Further, based on prior patches, we can no simplify the required condition
> 
>                                           "now simplify"
> 
> > test:
> >  - If range is valid memory then so is range->hmm
> >  - If hmm_release() has run then range->valid is set to false
> >    at the same time as dead, so no reason to check both.
> >  - A valid hmm has a valid hmm->mm.
> > 
> > Also, add the READ_ONCE for range->valid as there is no lock held here.
> > 
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> >  include/linux/hmm.h | 12 ++----------
> >  1 file changed, 2 insertions(+), 10 deletions(-)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 4ee3acabe5ed22..2ab35b40992b24 100644
> > +++ b/include/linux/hmm.h
> > @@ -218,17 +218,9 @@ static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
> >  static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
> >  					      unsigned long timeout)
> >  {
> > -	/* Check if mm is dead ? */
> > -	if (range->hmm == NULL || range->hmm->dead || range->hmm->mm == NULL) {
> > -		range->valid = false;
> > -		return false;
> > -	}
> > -	if (range->valid)
> > -		return true;
> > -	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
> > +	wait_event_timeout(range->hmm->wq, range->valid,
> >  			   msecs_to_jiffies(timeout));
> > -	/* Return current valid status just in case we get lucky */
> > -	return range->valid;
> > +	return READ_ONCE(range->valid);
> 
> Just to ensure that I actually understand the model: I'm assuming that the 
> READ_ONCE is there solely to ensure that range->valid is read *after* the
> wait_event_timeout() returns. Is that correct?

No, wait_event_timout already has internal barriers that make sure
things don't leak across it.

The READ_ONCE is required any time a thread is reading a value that
another thread can be concurrently changing - ie in this case there is
no lock protecting range->valid so the write side could be running.

Without the READ_ONCE the compiler is allowed to read the value twice
and assume it gets the same result, which may not be true with a
parallel writer, and thus may compromise the control flow in some
unknown way. 

It is also good documentation for the locking scheme in use as it
marks shared data that is not being locked.

However, now that dead is gone we can just write the above more simply
as:

static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
					      unsigned long timeout)
{
	return wait_event_timeout(range->hmm->wq, range->valid,
				  msecs_to_jiffies(timeout)) != 0;
}

Which relies on the internal barriers of wait_event_timeout, I'll fix
it up..

Thanks,
Jason


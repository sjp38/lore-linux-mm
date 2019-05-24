Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E914C282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 22:09:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAF74206BA
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 22:09:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="bKmgytC7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAF74206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D4C86B0008; Fri, 24 May 2019 18:09:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25E3E6B000A; Fri, 24 May 2019 18:09:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D7666B000C; Fri, 24 May 2019 18:09:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id D7D096B0008
	for <linux-mm@kvack.org>; Fri, 24 May 2019 18:09:26 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id j43so2599897uae.16
        for <linux-mm@kvack.org>; Fri, 24 May 2019 15:09:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N9WMPAq1SBJByj8qM7LaEK8FLATRoK2GkIV6yeIQrTg=;
        b=QTVAXLItkPOAAd2ONNfCRUVcpr2vRmn+qCIGSASN8Lj1hinqIPcYMbyknvByjeKCFC
         9NWMZ8gfd18F7vVS2dMJ21rz+0dcZY/LrrEtI8LrSFwEm8KdDVpU0s0jHuPrCSmUJgi2
         b9524SOSCErEszzPDoNneY9HomnEByDKWE2PgkDSbcwCINLSYCR7nf4xAnB6nFk+ZMzY
         0cqjEpBGftixTqVtgclPiCY0vTSZLdlh3oCO8o0cMHXSA1N52G+bAQZCd/hnk/+7i5os
         rlgJ/vz2MNnwbzh4PF0fvbPMggJsSsrwit2ujTs074mmbwX3BeLmWjdn9iuoIuz3EIbk
         eMBA==
X-Gm-Message-State: APjAAAWZwPC8+frUuyf7oZGkyKY+3xOKFLZMs+fLazHMnGM5a70N1tnY
	Ia8rcoQEEX5tuGIoQUTj6nW8yc9A+kDtafC+4imaIawirnr2tX67Bo0sz+jgo+kdt2/fZ3SAMLs
	shjgT3ZngqzHbc/jw0N1Ahkgz/E+NLqvfUjSudxapUGUzXB3TCQ+b4AIG3HZqPzf7oA==
X-Received: by 2002:ab0:348a:: with SMTP id c10mr9233933uar.79.1558735766539;
        Fri, 24 May 2019 15:09:26 -0700 (PDT)
X-Received: by 2002:ab0:348a:: with SMTP id c10mr9233856uar.79.1558735765843;
        Fri, 24 May 2019 15:09:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558735765; cv=none;
        d=google.com; s=arc-20160816;
        b=CoqBE8elkFMrPmibOBig2oH9/wk4okU5dcoqjlS0SugnEpehaUYFJaUDrdA80jPk9Z
         DBsxsRGqVxvl8L+zrP212eBzJvaP8PODLNC5g+4L3vwNQT7phlcGl+wJPKaUxMMuKlgm
         S/dDfhTr7maMZg9c/5FpMzJx76Vu/ykBMzVUdwzcT5zskFcnQmWRXviFAEx5+cLQ5BUa
         a+qnsexJ/BKGlweuKqAcP1Bi7B6au9r5DXB834/bO6nPI6DU9KBIKViZvaubY6JrHTA+
         5Tc+2O8dQTc4/xPY6MfaKZ15RlmRL2AfSCgck3MBFOhK4c7CG3h1HJ0BqvQ96PkK38cK
         5YEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=N9WMPAq1SBJByj8qM7LaEK8FLATRoK2GkIV6yeIQrTg=;
        b=QscW0JTUOrqpZ9fGdcny7lMg+QOeSidC4nPG8t4/Qc80ZEV2kwRmrzbqIBYXFl78cw
         cmMLYjmFN7PYa7fh0+XPXHTFRuDYR4Kk/PCG23t/L+I3wtLPNzKdtOVs5TLPIHtwF458
         QYsejLbizhirTwqG85Upb3XZ8zBi9ZCQtcQqmprURN7gy0lnvwNoNeKfDqeCp8pin3re
         IG8g3Tf3dV0USJgZuql6YFl+oPizYPCI6Jg5mui7BhV7eztz7Tmzg4BbfWsIETEo1Dqo
         JPvF8Ih1AGYiSX1hcUJNnRle+pVWYDFzInIK+Gh1bq0pxruIs8FSLULbTRXeZPTmUPH0
         B9tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=bKmgytC7;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6sor1672403vsf.6.2019.05.24.15.09.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 15:09:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=bKmgytC7;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=N9WMPAq1SBJByj8qM7LaEK8FLATRoK2GkIV6yeIQrTg=;
        b=bKmgytC7SrgoXWBeLhiR5hCTMa6fcLiMm5rC93YfDESWnXQkf9DWnWbpwOA2qai62r
         UQQrf8KjLit1Nysl+fEDFWUYjRQ1BCAU5L2WBIVkSkvA3HxAdgjSCgRcrkwYzG0lVhKA
         rkkm+QbUJn+xpBU32Ur7JFZ7RZnEvVuQ0Oh66ODXmdl++FyoKYM0Ut04eJ2K3+2AemGg
         DWabdEAuNWRwAaZALYzLij44xk2C0zYcEH2yx16sPHNGrOzr4f9fAGoOIdFEHsBFqwCQ
         KYvwVWtFbbfLv/HLr+MXFFfA2r3iSqVRvy/XUT9TF/l6/+fUUsNCW96LKaMe1KS1GPH8
         qURw==
X-Google-Smtp-Source: APXvYqwgrX8m55ZYTOzrECuhHF6YZsdnmGWgqzcToJx9OiFpqNA9rfK65uaAw5d6QYwQwUEAquscGg==
X-Received: by 2002:a67:2e15:: with SMTP id u21mr30135920vsu.50.1558735765273;
        Fri, 24 May 2019 15:09:25 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id v14sm2014695vkd.4.2019.05.24.15.09.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 15:09:24 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hUINP-0002IN-DS; Fri, 24 May 2019 19:09:23 -0300
Date: Fri, 24 May 2019 19:09:23 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190524220923.GA8519@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190524143649.GA14258@ziepe.ca>
 <20190524164902.GA3346@redhat.com>
 <20190524165931.GF16845@ziepe.ca>
 <20190524170148.GB3346@redhat.com>
 <20190524175203.GG16845@ziepe.ca>
 <20190524180321.GD3346@redhat.com>
 <20190524183225.GI16845@ziepe.ca>
 <20190524184608.GE3346@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524184608.GE3346@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 02:46:08PM -0400, Jerome Glisse wrote:
> > Here is the big 3 CPU ladder diagram that shows how 'valid' does not
> > work:
> > 
> >        CPU0                                               CPU1                                          CPU2
> >                                                         DEVICE PAGE FAULT
> >                                                         range = hmm_range_register()
> >
> >   // Overlaps with range
> >   hmm_invalidate_start()
> >     range->valid = false
> >     ops->sync_cpu_device_pagetables()
> >       take_lock(driver->update);
> >        // Wipe out page tables in device, enable faulting
> >       release_lock(driver->update);
> >                                                                                                    // Does not overlap with range
> >                                                                                                    hmm_invalidate_start()
> >                                                                                                    hmm_invalidate_end()
> >                                                                                                        list_for_each
> >                                                                                                            range->valid =  true
> 
>                                                                                                              ^
> No this can not happen because CPU0 still has invalidate_range in progress and
> thus hmm->notifiers > 0 so the hmm_invalidate_range_end() will not set the
> range->valid as true.

Oh, Okay, I now see how this all works, thank you

> > And I can make this more complicated (ie overlapping parallel
> > invalidates, etc) and show any 'bool' valid cannot work.
> 
> It does work. 

Well, I ment the bool alone cannot work, but this is really bool + a
counter.

> If you want i can remove the range->valid = true from the
> hmm_invalidate_range_end() and move it within hmm_range_wait_until_valid()
> ie modifying the hmm_range_wait_until_valid() logic, this might look
> cleaner.

Let me reflect on it for a bit. I have to say I don't like the clarity
here, and I don't like the valid=true loop in the invalidate_end, it
is pretty clunky.

I'm thinking a more obvious API for drivers, as something like:

again:
    hmm_range_start();
     [..]
    if (hmm_range_test_retry())
          goto again

    driver_lock()
      if (hmm_range_end())
           goto again
    driver_unlock();

Just because it makes it very clear to the driver author what to do
and how this is working, and makes it clear that there is no such
thing as 'valid' - what we *really* have is a locking collision
forcing retry. ie this is really closer to a seq-lock scheme, not a
valid/invalid scheme. Being able to explain the concept does matter
for maintainability...

And I'm thinking the above API design would comfortably support a more
efficient seq-lock like approach without the loop in invalidate_end..

But I haven't quite thought it all through yet. Next week!

> > I still think the best solution is to move device_lock() into mirror
> > and have hmm manage it for the driver as ODP does. It is certainly the
> > simplest solution to understand.
> 
> It is un-efficient and would block further than needed forward progress
> by mm code.

I'm not sure how you get to that, we already have the device_lock()
and it already blocks forward progress by mm code.

Really the big unfortunate thing here is that valid is manipulated
outside the device_lock, but really, logically, it is covered under
the device_lock

Jason


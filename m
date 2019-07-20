Return-Path: <SRS0=pjJT=VR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82DE5C76186
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 17:23:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C77A20823
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 17:23:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="isL+NyTl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C77A20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 497FF6B0005; Sat, 20 Jul 2019 13:23:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4497E6B0006; Sat, 20 Jul 2019 13:23:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3120F8E0001; Sat, 20 Jul 2019 13:23:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC4436B0005
	for <linux-mm@kvack.org>; Sat, 20 Jul 2019 13:23:20 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k20so20620456pgg.15
        for <linux-mm@kvack.org>; Sat, 20 Jul 2019 10:23:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=txlmNAr+NwP/f9mdJ1YbslIVZwuCfLJ/aWnHfkbj/ng=;
        b=rl+R8HXa3fpalSFV/gyKVSuKCw0n6jfvlFfOx8PegZeJj4+tcMuXnrFj4OGn2Yryll
         Irr7AkVi4F7XgadwPJMadFDJzfUTlQ0O5ybbpEwmPuSUiBytj6F696J5piuYbEnycY4X
         MiHyE+2fZoMPE/EYVK5jLsT0qaiqS8vv8/pofiX2syFdm6GAId60P0vJydkSoaD9tDnb
         FSjc9i2RVmDZRFwogiYad/xtP+QFlHMn9aADBkr44wcD8rxObaFaAo2Idy54hFT9yn40
         FW4pNpDb5dqY6FqzfWVYPNpHFocC0xJTOiCol73/kzwi8/yEeAZz4bvdIz1QqfTVBCdD
         iAbA==
X-Gm-Message-State: APjAAAWqg8NYJjvDxqYTlixAw/Qcczo2rGmWq2ZHu24EA0cXvI7AQbmk
	X5elSk11vDgAHG4fCPNE8wepX0yDHH97Blos1uAqfURSw/IIvQdvlQH6Tj5HRTgNRw7vCt4lned
	i4qYWUq4cmw36cWSruJC2SFawvUERJFJDIAnM3knJ/1yOpPhenFRnHaf3wUGVqtvXyw==
X-Received: by 2002:a63:b1d:: with SMTP id 29mr60981917pgl.103.1563643400312;
        Sat, 20 Jul 2019 10:23:20 -0700 (PDT)
X-Received: by 2002:a63:b1d:: with SMTP id 29mr60981826pgl.103.1563643399189;
        Sat, 20 Jul 2019 10:23:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563643399; cv=none;
        d=google.com; s=arc-20160816;
        b=HzLYgIkTnincYSrudoT0UOIoMPoFTEzcxQZcTfFWpcy7TnEH+T172iEeO28VmzVPbo
         cVj65pFfE6bcahIi7J02IAnciJdIOKsMhBSikpuz1UryU4soj7XLa+ZJKa9MEp6+BetG
         flNy5yhhhoDTG0vHV6FBDn1B2zBN2/cJcckdl2x7csbeAZ1TuL1nWmmRZrqGv9+Io+Y+
         tvg9syfrb3a/1o3IaDxn6lL9fklLja+8POIR1VS0ultcHS6DF/OOklvtKo4tSAl8sqbb
         hQYLECZoXIPkJ0IwhaoVnLaXDfppwUcYVNulzNA9R+k1y/lSpARPdwdC+wt7KnJffIve
         DgTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=txlmNAr+NwP/f9mdJ1YbslIVZwuCfLJ/aWnHfkbj/ng=;
        b=cH0xXAOqxpKFo0x+zGfyBpvja8iqgc9tY40R3rIHddztP+eFHvRJvQcg8T+9Pwktbq
         dBGs9Pmtm9acdEYHREH5+2IN/xhFwtDMJdzF8CQ1KbDXTeqCD3BH2xBVhqbSs3myO4JY
         pu+YymwBJjP9lr5/XYfZ9GgwvTf+ZC4CJHpGxW3yY9R7P/g7ABE0m4qUe+hoYUfAa/Lf
         aWiv7U0qSujemN80YR2+/8FhTK+vtrLkX+YAwNMGlT51lTDMCQ+SeRYEdpdMX77gQ69l
         FTox/uYxtpOjQcy6GG7hvxmoVjC3Wtj2rHWdOogSka3y3HYhDjqYDBswNe/HtpnfSrwL
         4AsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=isL+NyTl;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor42427604plo.54.2019.07.20.10.23.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Jul 2019 10:23:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=isL+NyTl;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=txlmNAr+NwP/f9mdJ1YbslIVZwuCfLJ/aWnHfkbj/ng=;
        b=isL+NyTlYKatZjFTLLfqQMg0bH6Qo/HekdDHYYQyy0/3Z0BEB0Lni/tM/zgCffMTlo
         pp/fcwL0AJmBktORv2+a/dWw5bi/ZETD8tcYWw67bseE2wutp+fHY4+hti+Bgw7FifTh
         rar99b/E/YQMC2gbksQ7RFRuIx155d42kI6PFFlV+5TbuSeMN2VeW9IDbCazpJGXdzjT
         YivtETGegS1Z8Qn5VSd3eoXoy4mVaDA7KLtQGo13DVqD2QgZKlSeFvfeH2DSOdHPVNF+
         sYwhOLHeauEvyz1vdFoxINz7om4yaMsaR+zpyaMjSw3X60I5xZjOG6eKMxltWJ1PaGWe
         yOwQ==
X-Google-Smtp-Source: APXvYqwCl+0p4loNmBy9AS8aE4DKp7ExSSZ0OLYl/twU5R0/mvD/0nbRoJXX34M2Lb+/fuCT11r6Qg==
X-Received: by 2002:a17:902:e306:: with SMTP id cg6mr64062158plb.263.1563643398778;
        Sat, 20 Jul 2019 10:23:18 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id q63sm46216384pfb.81.2019.07.20.10.23.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Jul 2019 10:23:18 -0700 (PDT)
Date: Sat, 20 Jul 2019 22:53:11 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: ira.weiny@intel.com, jglisse@redhat.com, gregkh@linuxfoundation.org,
	Matt.Sickler@daktronics.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org
Subject: Re: [PATCH v3] staging: kpc2000: Convert put_page to put_user_page*()
Message-ID: <20190720172310.GA3728@bharath12345-Inspiron-5559>
References: <20190719200235.GA16122@bharath12345-Inspiron-5559>
 <8bce5bb2-d9a5-13f1-7d96-27c41057c519@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8bce5bb2-d9a5-13f1-7d96-27c41057c519@nvidia.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 19, 2019 at 02:28:39PM -0700, John Hubbard wrote:
> On 7/19/19 1:02 PM, Bharath Vedartham wrote:
> > There have been issues with coordination of various subsystems using
> > get_user_pages. These issues are better described in [1].
> > 
> > An implementation of tracking get_user_pages is currently underway
> > The implementation requires the use put_user_page*() variants to release
> > a reference rather than put_page(). The commit that introduced
> > put_user_pages, Commit fc1d8e7cca2daa18d2fe56b94874848adf89d7f5 ("mm: introduce
> > put_user_page*(), placeholder version").
> > 
> > The implementation currently simply calls put_page() within
> > put_user_page(). But in the future, it is to change to add a mechanism
> > to keep track of get_user_pages. Once a tracking mechanism is
> > implemented, we can make attempts to work on improving on coordination
> > between various subsystems using get_user_pages.
> > 
> > [1] https://lwn.net/Articles/753027/
> 
> Optional: I've been fussing about how to keep the change log reasonable,
> and finally came up with the following recommended template for these 
> conversion patches. This would replace the text you have above, because the 
> put_user_page placeholder commit has all the documentation (and then some) 
> that we need:
> 
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
Great then, I ll send another patch with the updated changelog.
> 
> For the change itself, you will need to rebase it onto the latest 
> linux.git, as it doesn't quite apply there. 
> 
> Testing is good if we can get it, but as far as I can tell this is
> correct, so you can also add:
> 
>     Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Thanks! 
> thanks,
> -- 
> John Hubbard
> NVIDIA
>
> > 
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: Matt Sickler <Matt.Sickler@daktronics.com>
> > Cc: devel@driverdev.osuosl.org 
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> > ---
> > Changes since v1
> > 	- Improved changelog by John's suggestion.
> > 	- Moved logic to dirty pages below sg_dma_unmap
> > 	and removed PageReserved check.
> > Changes since v2
> > 	- Added back PageResevered check as suggested by John Hubbard.
> > 	
> > The PageReserved check needs a closer look and is not worth messing
> > around with for now.
> > 
> > Matt, Could you give any suggestions for testing this patch?
> >     
> > If in-case, you are willing to pick this up to test. Could you
> > apply this patch to this tree
> > https://github.com/johnhubbard/linux/tree/gup_dma_core
> > and test it with your devices?
> > 
> > ---
> >  drivers/staging/kpc2000/kpc_dma/fileops.c | 17 ++++++-----------
> >  1 file changed, 6 insertions(+), 11 deletions(-)
> > 
> > diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
> > index 6166587..75ad263 100644
> > --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> > +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> > @@ -198,9 +198,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, struct kiocb *kcb, unsigned
> >  	sg_free_table(&acd->sgt);
> >   err_dma_map_sg:
> >   err_alloc_sg_table:
> > -	for (i = 0 ; i < acd->page_count ; i++){
> > -		put_page(acd->user_pages[i]);
> > -	}
> > +	put_user_pages(acd->user_pages, acd->page_count);
> >   err_get_user_pages:
> >  	kfree(acd->user_pages);
> >   err_alloc_userpages:
> > @@ -221,16 +219,13 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
> >  	
> >  	dev_dbg(&acd->ldev->pldev->dev, "transfer_complete_cb(acd = [%p])\n", acd);
> >  	
> > -	for (i = 0 ; i < acd->page_count ; i++){
> > -		if (!PageReserved(acd->user_pages[i])){
> > -			set_page_dirty(acd->user_pages[i]);
> > -		}
> > -	}
> > -	
> >  	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
> >  	
> > -	for (i = 0 ; i < acd->page_count ; i++){
> > -		put_page(acd->user_pages[i]);
> > +	for (i = 0; i < acd->page_count; i++) {
> > +		if (!PageReserved(acd->user_pages[i]))
> > +			put_user_pages_dirty(&acd->user_pages[i], 1);
> > +		else
> > +			put_user_page(acd->user_pages[i]);
> >  	}
> >  	
> >  	sg_free_table(&acd->sgt);
> > 


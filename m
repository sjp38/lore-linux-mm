Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44522C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 19:33:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C61E9218A5
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 19:32:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="zxZsAqHj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C61E9218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 273B56B0008; Fri, 29 Mar 2019 15:32:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2226C6B000A; Fri, 29 Mar 2019 15:32:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 115296B000D; Fri, 29 Mar 2019 15:32:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA4446B0008
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 15:32:58 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id t66so1325834oie.3
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 12:32:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=s4Yzf+CeFFZ/OjTiJqtBkGZm16+m8nmoCemxugx67kE=;
        b=bEOSUcIzo973QJFyy9VFzCs2D5nNdNiCbA/QP9YLrWGqMaOp1iDGj67U43sIdtfuTE
         Hp7hgB/ffT1+WiKYYwMcWthRGdeADhDdW0KwQhKm1c6GPwQapRKWWpP3yCdvWqBsnZ33
         WeyMaxSKpoCgaum757YfQMa8P7ywyYYLtBJfxN19758RpEpMCzbfF2RzWgjT3ogDCnRo
         LbgVjhN9PIp9uvh8dfGNBZAgd7sf3IJDPGDkebhpLHU6rtSyfh6c96lsAkKknokGrOmX
         ECD45Qd0U64Vpdn/bHBRbvMw7YdTRkaysUZ+Jlci7pwPE8kalS0coT1YodyxQL/ySr22
         dq1w==
X-Gm-Message-State: APjAAAWqIqbo6xoLNi4HTLgAp01cuuQl2zfVlrJxOyK7qL5iRzqJx5ao
	G5ptoDlcLxy2Xkajr3ms7cqtBFKri+dzG7JrHnpd7qeoSSy8O6eJhk0QfQ6vX3nKdW9mDADoVIV
	Y1/c7FxgsOs3Ve1B5qY3H1CKfAY5iQ4Ij8VTSAHUwWpnhish9AECeNP7UGD25xOML1Q==
X-Received: by 2002:a9d:30d1:: with SMTP id r17mr34635044otg.331.1553887978365;
        Fri, 29 Mar 2019 12:32:58 -0700 (PDT)
X-Received: by 2002:a9d:30d1:: with SMTP id r17mr34635000otg.331.1553887977619;
        Fri, 29 Mar 2019 12:32:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553887977; cv=none;
        d=google.com; s=arc-20160816;
        b=pLV/Pg/b5XLnfb8l2Peqn7DSJa4mTIzaOZz6M8p1yhWllaaJTBM0dTomA1tZy9XQHc
         z1SjFJUZOS89rzYTgfEZWSvlcWiKnc0dTfWFS6FhF6b8orRLa0ScB2ZpJZP4zEb8jj97
         5wmNOR5jWQlB0oihepW1CgGgwAsrfgnb6pH9odpehZdCSav2zR3oV4CtePrheq3l50kj
         qRExTEBXZC3F5SXIHOCE8WXzRMQ3H9SvZ7FOK00O4GMMxwLYSGECSYVa772z/p7pfA72
         LIses5eLnXudDThHHRij4d2kp//p1xPnWEMONA7yp/cyeu+CwHBbExtoCe2Lid3ECp/S
         hIkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=s4Yzf+CeFFZ/OjTiJqtBkGZm16+m8nmoCemxugx67kE=;
        b=UwXycpRO52/53TcmDHZ9cPRPBYBTUo9CCxcU0wbMQjpSuHO/mteDWchIz5+5clAgzq
         1xUWRy71ScGmsqBwVG92nEFGCV2VOcQ4b5EoRHa0/gL7j/M4M7SOAib1iW83Wv09gjlY
         vxfUW21jRJIl5vpbWGvNKQGNnGfvhpfwVZH2Up3I0tL3LuDxKlmqBHYNsu0CzirjXhkc
         b9pzIq71dWyfILgBtWTuEMiwdxEFPuRLKQWvcEvsXshxi0zWDT55/w3NYLtalUPL0Nfq
         6KwE3SUjXmGYKzcbmlFoxRFnMfvfiN4gXO++GW5hglxy4IY+cf1Db2P72mW2RG0cQi4q
         jNaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=zxZsAqHj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g13sor1898610otk.126.2019.03.29.12.32.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 12:32:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=zxZsAqHj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=s4Yzf+CeFFZ/OjTiJqtBkGZm16+m8nmoCemxugx67kE=;
        b=zxZsAqHjy2Y9Bx4xA6zF2h+1CbpYruowgarysCor6ANLjnLGePYd87HqKjmFW25UWN
         hPmO2ck4OPgaGeQJMv8/EEEWlng/kHNbGlTXKS9B7dGBi52AxxxV7mqOV9YXV5s+J5b9
         46KrNLdVwWVSeUEdKUIQw/11HOobEoq2gXKv+Ga7wH72ZXFc4MPtFwgfzMiF0D+OiWtu
         Se/2SEFgkY8o67XAMWtQQSHCVzrAgci4FUoJViyvTORZHdqQ5expOvSUC5Zwch0xld1d
         4v7hpaOQRzUd704JnvlH6thRYy1kNEZd0zkL28FI61mqAGS3TN04F6ZYcALuPCb/a4dK
         qApQ==
X-Google-Smtp-Source: APXvYqwKKdJS1Ua99aSwjJMfej/Pl2KR1kuLlRSNXUVME1MVVPAjFR1jZGMaGITHccVokDGIy7QDL3CNtMKk6tuVlMc=
X-Received: by 2002:a9d:7749:: with SMTP id t9mr6559409otl.229.1553887977043;
 Fri, 29 Mar 2019 12:32:57 -0700 (PDT)
MIME-Version: 1.0
References: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155387327020.2443841.6446837127378298192.stgit@dwillia2-desk3.amr.corp.intel.com>
 <cfda881b-d99c-7c53-64cb-745ff4b257b0@deltatee.com>
In-Reply-To: <cfda881b-d99c-7c53-64cb-745ff4b257b0@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 29 Mar 2019 12:32:44 -0700
Message-ID: <CAPcyv4jZiK+OHjwNqDARv4g326AQZx7N_Lmxj1Zux_bX1T2CLQ@mail.gmail.com>
Subject: Re: [PATCH 5/6] pci/p2pdma: Track pgmap references per resource, not globally
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, 
	Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, linux-pci@vger.kernel.org, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 10:50 AM Logan Gunthorpe <logang@deltatee.com> wrote:
>
> Thanks Dan, this is great. I think the changes in this series are
> cleaner and more understandable than the patch set I had sent earlier.
>
> However, I found a couple minor issues with this patch:
>
> On 2019-03-29 9:27 a.m., Dan Williams wrote:
> >  static void pci_p2pdma_release(void *data)
> >  {
> >       struct pci_dev *pdev = data;
> > @@ -103,12 +110,12 @@ static void pci_p2pdma_release(void *data)
> >       if (!pdev->p2pdma)
> >               return;
> >
> > -     wait_for_completion(&pdev->p2pdma->devmap_ref_done);
> > -     percpu_ref_exit(&pdev->p2pdma->devmap_ref);
> > +     /* Flush and disable pci_alloc_p2p_mem() */
> > +     pdev->p2pdma = NULL;
> > +     synchronize_rcu();
> >
> >       gen_pool_destroy(pdev->p2pdma->pool);
>
> I missed this on my initial review, but it became obvious when I tried
> to test the series: this is a NULL dereference seeing pdev->p2pdma was
> set to NULL a few lines up.

Ah, yup.

> When I fix this by storing p2pdma in a local variable, the patch set
> works and never seems to crash when I hot remove p2pdma memory.

Great!

>
> >  void *pci_alloc_p2pmem(struct pci_dev *pdev, size_t size)
> >  {
> > -     void *ret;
> > +     void *ret = NULL;
> > +     struct percpu_ref *ref;
> >
> > +     rcu_read_lock();
> >       if (unlikely(!pdev->p2pdma))
> > -             return NULL;
>
> Using RCU here makes sense to me, however I expect we should be using
> the proper rcu_assign_pointer(), rcu_dereference() and __rcu tag with
> pdev->p2pdma. If only to better document what's being protected with the
> new RCU calls.

I think just add a comment because those helpers are for cases where
the rcu protected pointer is allowed to race the teardown. In this
case we're using rcu just as a barrier to force the NULL check to
resolve.


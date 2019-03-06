Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAC9FC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 01:32:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BA0A206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 01:32:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="JRjGlCOK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BA0A206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06C1E8E0003; Tue,  5 Mar 2019 20:32:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01A728E0001; Tue,  5 Mar 2019 20:32:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4B688E0003; Tue,  5 Mar 2019 20:32:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B96C58E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 20:32:16 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d49so10068073qtd.15
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 17:32:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LgoNOQGVlVerTL6CkbzBmMfQoLEg7pV/lg0gy2aIImA=;
        b=sBsPWbEszbn8hWlrc0GD9fxeA8JviOjg1P7tm4Cd0CHawO/UE3lizdxz8HuOOZcf1Y
         nDs/QYBT+O4djK9Zm1H5LrYdTXyWqHURySRuaZn0Rp39XZkggfFLgEvdGLiC/6EhXmQR
         PMOJo/Svbw2wIRKQjLRtjaEaGUytcLzCTDomskbmGFnuijL0rJgh0HvyMu+r49Cm8U5S
         T7HQyLer635zGGJECA+ymfw0QbatQ9Yjmrat2HGFu+0gkrQSfHs7qsEkqd2UG4n+ltXb
         c7kSkofmGZJtpHzgaisVOBkDzpJSyGsi4eyKthCdPzYh16LdrAJu9jf3WU/fX3OGzbML
         Zt1w==
X-Gm-Message-State: APjAAAVqST+q/aG6cWP2h8VQr/M6lPOOOl7REK5/pQVlfF76NHy/wE4B
	vbCKemqFMnZwt/XnzNxKnOLlul1rNeLFjQVWahJSujKczobQGfcA3+/MPhcEGEdGkjvZuxi4cAS
	OSmsVHJujCXn/MivmZKYGxX+ITKFd2MqdPU7xLVrChTSNvNU/9twuudsXBI93zhKWwzBJo+hIsZ
	EboamldCA+uhVNhCnjY64CGNGLigM7wQJxgvUmvhsjNW4g2/m7kXIFwqrCf3UfGZ7JZX8u7wWfg
	UqNNuQJqhKqVsWktIokHMBAImNEbpZXwPgdS6bgxpX2e1ZGKlbZrKZhasSK1VjEnj+x3QTAJC2a
	TDjrS695Oio088si4o1wcl+YWREM/n48Oby5kEStWEQ2nTrl4dQRNVkDYxZGJpNWnwk65uAEOno
	0
X-Received: by 2002:ac8:1bd5:: with SMTP id m21mr3636883qtk.89.1551835936463;
        Tue, 05 Mar 2019 17:32:16 -0800 (PST)
X-Received: by 2002:ac8:1bd5:: with SMTP id m21mr3636848qtk.89.1551835935518;
        Tue, 05 Mar 2019 17:32:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551835935; cv=none;
        d=google.com; s=arc-20160816;
        b=M9tdZhlaSHq8k7572bAeKTUaiMat8VLaMwIuAhPQkDEE3KNZPDO3Q1yur9vPxwQCo/
         mQnncbu7+FODAZZsx9IdZgGUjpwVv5YT1tkucQWCuSRcXIT5eR97lzae101275jpVTEl
         QYUgE23iko1n+6rxvXAI9SbYrIs+/wJUBDdBVjHc9ouGD9gd58m/Y3UpMUB5ZbafogkA
         MdWgHdYlGaUffx55DOgcz458meciok7KYIopBk5l4hDE5CEuyV0wptUf7gphsuwNh2hs
         N1SNhgaUbc3Fm+xyVmonf5XkQ7fLsSwg9JOwTjh61IT+ewLfFmyBIxQLJe5cuEutYWTP
         1Ssw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LgoNOQGVlVerTL6CkbzBmMfQoLEg7pV/lg0gy2aIImA=;
        b=jNvo+EB2br4FbAl0/zUy/uTS6uBv6kdz3UMTnkYdU2ABFx35BKdtoU6L3MYV2oSuhB
         Faz5cBPlFUpVUdRwJpwlwg/8WMe6E3LUm6BpGi8Z3XFtFjh02SK5Z2KCxqyPDfz09cau
         0d4sffeQ/fauD6s/qj7T/mwNsLthjn+ibxiNC7+XJfDNbjMc01FUhO/W6FnWyZT/SYcv
         zmJQVIQCXzdhp/brMmrO9+xGUW8B8Z7ztj9XqHHId1qpQahN7xHgCpoYMxlW+Xt6zlSM
         UxBxPg/E9PN7PKblsCQzyHHz+3ebkbhrPfBWVkZBKpAC6yirsU67htHMkZK9y5wodYAZ
         bpwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JRjGlCOK;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 191sor155596qkh.121.2019.03.05.17.32.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Mar 2019 17:32:15 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JRjGlCOK;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LgoNOQGVlVerTL6CkbzBmMfQoLEg7pV/lg0gy2aIImA=;
        b=JRjGlCOKs8wItxm0entX9rujZvzkRAII4BOKp6jB5luJOeHJb9YbCs8TwIs4jpZYQI
         fbacOgDnupqZc2tg7drOzMFLGU2Gl/8abzn+R8wiqMLfrtugSLbIHWOFcuicbHZya5YR
         SW8r8Lxp3tg/F1g6Q/2VqLcjjZKtQyCyfsyMggvaRqA3ZmE8Wkbhdipj/Yfo6plmAQpq
         E8rDWp8yPzGELmZDQzL2wlbAVE/wbYwmWB8V1vVRkvw6cHZVKU8D1hf7xeGHkGrnnEWg
         s/vLSM0HqG9tR56O4eyPrpl9vMH2TRkTXyEkZE9sIm3cck+m9a+ZgjAwesZKGWHQuw+y
         Tniw==
X-Google-Smtp-Source: APXvYqwOwuDPdIm3i+RCGmlGOgPdC6Eqs32vJh04KZPR3wugqMiT1SQj4ve03YID4AqVeBJBheEcYQ==
X-Received: by 2002:a37:9f04:: with SMTP id i4mr3786299qke.221.1551835935107;
        Tue, 05 Mar 2019 17:32:15 -0800 (PST)
Received: from ziepe.ca ([24.137.65.181])
        by smtp.gmail.com with ESMTPSA id o5sm215033qkl.24.2019.03.05.17.32.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Mar 2019 17:32:14 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1h1LPp-000230-1Y; Tue, 05 Mar 2019 21:32:13 -0400
Date: Tue, 5 Mar 2019 21:32:13 -0400
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Artemy Kovalyov <artemyko@mellanox.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error
 handling paths
Message-ID: <20190306013213.GA1662@ziepe.ca>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <332021c5-ab72-d54f-85c8-b2b12b76daed@nvidia.com>
 <903383a6-f2c9-4a69-83c0-9be9c052d4be@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <903383a6-f2c9-4a69-83c0-9be9c052d4be@mellanox.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 03:02:36AM +0200, Artemy Kovalyov wrote:
> 
> 
> On 04/03/2019 00:37, John Hubbard wrote:
> > On 3/3/19 1:52 AM, Artemy Kovalyov wrote:
> > > 
> > > 
> > > On 02/03/2019 21:44, Ira Weiny wrote:
> > > > 
> > > > On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrote:
> > > > > From: John Hubbard <jhubbard@nvidia.com>
> > > > > 
> > > > > ...
> > 
> > OK, thanks for explaining! Artemy, while you're here, any thoughts about the
> > release_pages, and the change of the starting point, from the other part of the
> > patch:
> > 
> > @@ -684,9 +677,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp,
> > u64 user_virt,
> > 	mutex_unlock(&umem_odp->umem_mutex);
> > 
> >    		if (ret < 0) {
> > -			/* Release left over pages when handling errors. */
> > -			for (++j; j < npages; ++j)
> release_pages() is an optimized batch put_page() so it's ok.
> but! release starting from page next to one cause failure in
> ib_umem_odp_map_dma_single_page() is correct because failure flow of this
> functions already called put_page().
> So release_pages(&local_page_list[j+1], npages - j-1) would be correct.

Someone send a fixup patch please...

Jason


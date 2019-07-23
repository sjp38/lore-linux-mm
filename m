Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A123EC76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 16:19:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B8DE20823
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 16:19:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B8DE20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E402F6B0007; Tue, 23 Jul 2019 12:19:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC9E28E0003; Tue, 23 Jul 2019 12:19:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C923D8E0002; Tue, 23 Jul 2019 12:19:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 912736B0007
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 12:19:10 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g2so21067366wrq.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:19:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sCH/wuNhaXWPuLd4shr34nF8l/MIoiLg6dyLUAratJg=;
        b=KabOW3tHDs+bq6D5CnS+UsHQyIu1Fqg+bt32dlRd7EV0TGjzTaNxgVLPuPnk8UmtT0
         f7vBb4s8qD1/qws3/zMHT33qvUMuHTiKbRkZLzedRZSzbtCgGx5r7CjjisFBtEmdCmv6
         AtWOqGhA9C1fBy+8BZsivmAl2v17xwDnf5wyATgHc++HjjHpjwQCTXxJgpi9w06dWtvj
         +IS3CZyaE7mjXL/f5LzM0IJ5UTLMMVBcm1Qgn2b7NeQ2pMqmjCLLOUJuYiFi2BrwhAED
         ZTp8uBezQN3hj+lCeA+zW6MCCDD3/5gG7oyqpslO7kiVrqnYz55+JCbLTLYQF6whqb7i
         vGiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVu4xQpQgJ0A0GLOlewdcISH4gv6XzuB7OAkvS1dBlln5aEoW6e
	p2Cy09+rE07Q5TAXx/69kr2oWdcbhCPnl/CS+LnGmZiS9CNdN25M9vl4HhwtndM69v2PglxkVk6
	wdcsQo3k7os1HIuOcvtCofThOQLHWFLAwKI6Nu4bzz7yfQQ6JJq5YfevXS+lSZanHFg==
X-Received: by 2002:adf:f60a:: with SMTP id t10mr43338429wrp.258.1563898750087;
        Tue, 23 Jul 2019 09:19:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhVi5EGOJqzHX+OHdwQxPaNTigjadq62Hv3YQhHkDdAUruraeHliTRcIu9vSH3Ul3MUk/Z
X-Received: by 2002:adf:f60a:: with SMTP id t10mr43338370wrp.258.1563898749249;
        Tue, 23 Jul 2019 09:19:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563898749; cv=none;
        d=google.com; s=arc-20160816;
        b=S3ZbylymcCy2gql9vWUCy9Xa6WIxy9pczBZy0UEF/Wo0CK/Tv9hi76teR7SM0P4XDr
         eDbBc63D84mbkfelUESQygGrFX6k5GKH4HX+9Gk5Qmrfz1HDLgAXVXoHQbDowGyPs6Oo
         vSPBt1x7H/xNquPeApsVi7AR0RV3HWOLHV00jsAcJ5SZKVk496ofT0hXkOXQfTSG7ibg
         +8HC7L1E/pK2VaqjbG4NoiEOmfF3roa1ivRFkMj2rT/e55W0EgVrRFdkc8fum7K2ztW0
         TNPeapYyUKFkDgimBKc+nqDKfp8CD+qrMI6MDZGmGus/nErlcMRJTwRbhIjc+HJw+Td2
         xDqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sCH/wuNhaXWPuLd4shr34nF8l/MIoiLg6dyLUAratJg=;
        b=w8ZNp04OUm3ZhmUE7Rv8zOUqMsuAvJiADJv7qTBEyeEfrAsAfds6Ct8MZXAUNMa+0a
         ex3raB8MwLKgCwIdv8AOBEDlyCHl3ghgmD2r4nY3568JRSk153mpX3WLD8X03DtDMnVA
         P79vqBDvtLfNC0NsJlGuBHQcgh9n/cFsAm5iM83fKsEhV81PQMewx81QzkBRHJwQCkc4
         ndrKSWAkIzoaQAk2I0mF8+exw6ul7oPJwJRV8+1qBTAA9A5FpRbNdI9gZTPOX4xhNGJA
         k/baKPDW/IIqYwBm+7MnzFTT0q+P2fAk8E32e49h+dibttHQ3YMOdChvdkqqY81lnYyF
         tYRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x14si27946367wrr.100.2019.07.23.09.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 09:19:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 1950868B02; Tue, 23 Jul 2019 18:19:08 +0200 (CEST)
Date: Tue, 23 Jul 2019 18:19:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Linux-MM <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Subject: Re: [PATCH 1/6] mm: always return EBUSY for invalid ranges in
 hmm_range_{fault,snapshot}
Message-ID: <20190723161907.GB1655@lst.de>
References: <20190722094426.18563-1-hch@lst.de> <20190722094426.18563-2-hch@lst.de> <CAFqt6zY8zWAmc-VTrZ1KxQPBCdbTxmZy_tq2-OkUi3TVrfp7Og@mail.gmail.com> <20190723145441.GI15331@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723145441.GI15331@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 02:54:45PM +0000, Jason Gunthorpe wrote:
> I think without the commit message I wouldn't have been able to
> understand that, so Christoph, could you also add the comment below
> please?

I don't think this belongs into this patch.  I can add it as a separate
patch under your name and with your signoff if you are ok with that.


Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B612C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 08:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CEA520656
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 08:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CEA520656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D19686B0007; Thu, 27 Jun 2019 04:52:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC8A58E0003; Thu, 27 Jun 2019 04:52:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B92CC8E0002; Thu, 27 Jun 2019 04:52:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 830076B0007
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 04:52:07 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v14so791736wrm.23
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 01:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QFr1m8dau1BcostLGcT6znX5sNiUQrk0Zi3ncilVCjQ=;
        b=U7ZFHJ9Ca/tW3kx46gcl/kxS7lNUuji6ny0MmfPbi0lrZT4bGSpTF7gtw4Hucdo1K0
         IEv0A7V2Biq1KWteq3gj3ScXPyqKLSKAs/vB/EU+ne7CInDJ8gzmxkpwCwyjvHhhyZv1
         JAtoeWEoRC3enZs+5It2TJ7fwzEIAHN4cTQlqV7DMlq6BMy13IKgrT8oVuZ1UVXaSRj1
         NjVT6OAbOM8VtOsePuUqQxYgMyooBt/ow3DYvhrsK6LS/nvEJ5mf3Q/jqEgP2ZE33tzz
         a8MqsC/leaYlgiE1nyQcdiiy8bsX7vv7hp0C8+zKYrsSCvClotgC0uXEUM930bglURI4
         u4JA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUimVYX6OuZ+QYOoowuIUyjCmYw1RjozSG9WDKPk0RKSTlSFWV+
	CGhoL+BCvbRB2t2c4LJxXR3K66qnHx3RZUAb5+YXQcKg7FHWQKX5PL5SE34zYFvObX2DOIVuxu4
	Kep0QOd2JmcLCOxkdyK/Emkyk6BhF2SkJxDUBcFaX3Uz7fxd27UjHJTB/WqJVRrGZZQ==
X-Received: by 2002:a05:600c:204c:: with SMTP id p12mr2351706wmg.121.1561625527140;
        Thu, 27 Jun 2019 01:52:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRg5OhvhtEcuH3kNr4sOy5eYay8zyTl6eSMk53aMyke8+4la4dkn5iG5kIE/NpJoTLmI0k
X-Received: by 2002:a05:600c:204c:: with SMTP id p12mr2351650wmg.121.1561625526489;
        Thu, 27 Jun 2019 01:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561625526; cv=none;
        d=google.com; s=arc-20160816;
        b=q3P7gSaOXZv7yXxdqsdMnqfZmJK+nbDMyyzYeK07IS/r/WNxkZZ4OiObGNobzuAVpH
         SNpSb7HB4B+/WVsh3sgALUKdtG7/kIB1WXTGCngW/xXjpi9ECElLJdm9HWl/kKmo9JxZ
         KX04/55HCCz+iFe1rZZYZ7Y0svNrxbQjNk9fqfvL1fCl4cwwYUB5wDG3n8PDY3WidIVL
         0IxOldQMUJ+1Z2VXIsfImcIH4UA3x88CzarUHNyuTH/i4BowDuc6yOwhwJU6If7AX/FZ
         PhJwyugaiVWOnyBU1kktT5nyxEKYrG/HRYkOrZExOgywioHYbHY2yoDm2vHtXkYnT5j/
         EAAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QFr1m8dau1BcostLGcT6znX5sNiUQrk0Zi3ncilVCjQ=;
        b=GytZnpiOTns4hMjVsPO3iM8Rjy3/DRkjOqlUEeBjfWyfjj8XF56zeVHhssh+ihXeL7
         b/OQ8ZafI31nDeLuQoIrM8UJ85fG3P6X4f1viPqWgdsMq0TWN1G3cD7TVHiymOhCU+8i
         36ded12E4pfFx/iPCfiKGSLsQBBws1tK1c0HO1r7dDL9uQTY1//SSa1i1pu2VBlhy8CJ
         0N+C3aBIZND1ncXf7q0UZLPQeZpxP82tNb2MhmLvpoIoC039EQG2eMk1TBOFhw+vAtmh
         moT0bEfsaJTXPkSN9Cjixu6mg00zoejkDI0T4UC2Otvqr9U5Slv1yx1yY9NO2D7QYcRT
         YvSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x2si3116359wmh.163.2019.06.27.01.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 01:52:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id B4FDB68B20; Thu, 27 Jun 2019 10:51:35 +0200 (CEST)
Date: Thu, 27 Jun 2019 10:51:35 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 15/25] memremap: provide an optional internal refcount
 in struct dev_pagemap
Message-ID: <20190627085135.GB11420@lst.de>
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-16-hch@lst.de> <20190626214750.GC8399@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626214750.GC8399@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:47:50PM -0700, Ira Weiny wrote:
> > +
> > +		init_completion(&pgmap->done);
> > +		error = percpu_ref_init(&pgmap->internal_ref,
> > +				dev_pagemap_percpu_release, 0, GFP_KERNEL);
> > +		if (error)
> > +			return ERR_PTR(error);
> > +		pgmap->ref = &pgmap->internal_ref;
> > +	} else {
> > +		if (!pgmap->ops || !pgmap->ops->kill || !pgmap->ops->cleanup) {
> > +			WARN(1, "Missing reference count teardown definition\n");
> > +			return ERR_PTR(-EINVAL);
> > +		}
> 
> After this series are there any users who continue to supply their own
> reference object and these callbacks?

Yes, fsdax uses the block layer request_queue reference count.


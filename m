Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 431FEC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:24:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F392020850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:24:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F392020850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E4098E0003; Fri, 14 Jun 2019 02:24:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66B8A8E0002; Fri, 14 Jun 2019 02:24:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55AD78E0003; Fri, 14 Jun 2019 02:24:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B05D8E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:24:00 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id a11so642054wrx.2
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:24:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LgGH3qJ+3mu+hBpTXAJXLihKCcQqkJmGk/t28VDJmdk=;
        b=H/xZN+pG/JugyewTPHDEkNHGcJYrGrWXAtFxOu/BdHe7soq8IKDzLVj39nLcNYrxvz
         6L5GTMw/v75e4AdnlOqNQQ8JqWAsVQ3UkWgZtw+aUD86TJQaqT57/jBQINHoWOcR6b9h
         779fywsWuNDiImvD0AJZWbukS6JeGeit5hTURYcpb7zRRPGvO77MEKBidxHL3oM38atG
         XbQFCPJGDPZvsBa3xnVfbZ+tgCQ2OcycpBJNDxvuH5t0s57yJW082/zv2omYIq+MHKLj
         jwNeBopQTeCqZ1i0hmTMk47elcHT3XTY9/dESrTfrHU5nd3bb4PjRwkblxLlis8fIgyw
         5+pg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXYMwpopwuRrHf5Loq/vfGbOIW71mEfVEhht3Q7n1fGQQO6yeiC
	ZxTewGnK/d1ohTGZFojd1djyAzeG/vBk5sl0uEmk2n0LVZQUQnstJrItJ0s194NGqFsJ/ElIsnX
	8sbDnDhPeSI/nL+yIuXY5/ex4CwFKeOefhqRFFRprLPHTIpQoHJrPLuwmUGNaQ3RV2w==
X-Received: by 2002:a05:600c:28d:: with SMTP id 13mr6516237wmk.5.1560493439594;
        Thu, 13 Jun 2019 23:23:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxD0XIZj9sAEGg/PlDJ7qxCBA+EXb39ie+GgibCXGo7nbVcwFIkFd+EDK7Pclbe8N2LCiNH
X-Received: by 2002:a05:600c:28d:: with SMTP id 13mr6516206wmk.5.1560493438913;
        Thu, 13 Jun 2019 23:23:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560493438; cv=none;
        d=google.com; s=arc-20160816;
        b=liRCPr5632Z7g3pYZyNhl70EtUPgx+Y3U5K7gu2LT47qY7T271SrkmBbNYahmd/gOy
         neebVQ5ljLzj58cAfaTDC0+6ptpTWqqsrVIFVQ2euJ3XPMZ9nJhlZ0ryQkytGGp+j3ea
         FlpDy8JG6Ei4gJlbLP9oGIipSS0ga3aH3mzm363o+AQJ5zeXdJgfEazegGFKiPBvqr4e
         91PKclRltNhDIZDG147qror9hBR9Mkm+e6XLHgraOXGIdALR4+etoKN55uKsjikAH/iJ
         eKnev8aP3Knug6ZCb6QQYFx9E1MHrfdUWgkkkvi4gYIQvFEb905yutNZNINDrvzgBzM/
         uy3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LgGH3qJ+3mu+hBpTXAJXLihKCcQqkJmGk/t28VDJmdk=;
        b=IXJpEaFhhfFqMoa043o1Iyqaab9laEEcC3VnwwgKK7u4AHL1hVou7ginpUqmX5I3lr
         Aij16a0kiYpL1Pj9wWxHQ9klMajRHndZGUgvgBtm6WV7hPQj0KOuPbsEFrDdxV6w+CTV
         OG9ak7LjKBWnNdE618iVl6Om4iF9YW/gw47JzDXlRCc/XC321D0K4wkiz+gHD5QLvWdI
         Uvv2RcL8aGpzH8di08rHXyBjdYGL8X8Q3CQrNKfYQVertMJ/GfJOLZq4r/YtOQROW6JD
         4YGPilCBCmirNPxIzw5rZITGUcT2dQKw51aOz3cD9Hf1vhsWOcOq7wI0gCwa7/f/9+dO
         0APQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d15si1596444wrm.1.2019.06.13.23.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:23:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 50BC268B02; Fri, 14 Jun 2019 08:23:31 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:23:31 +0200
From: Christoph Hellwig <hch@lst.de>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
Message-ID: <20190614062331.GG7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-6-hch@lst.de> <d83280b5-8cca-3b28-1727-58a70648e2b9@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d83280b5-8cca-3b28-1727-58a70648e2b9@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 06:47:57PM -0700, John Hubbard wrote:
> On 6/13/19 2:43 AM, Christoph Hellwig wrote:
> > noveau is currently using this through an odd hmm wrapper, and I plan
> 
>   "nouveau"

Meh, I keep misspelling that name.  I've already fixed it up a few times
for this series along.


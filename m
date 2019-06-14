Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8C12C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:36:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F627208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:36:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F627208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CBBA8E0003; Fri, 14 Jun 2019 02:36:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37B1D8E0002; Fri, 14 Jun 2019 02:36:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26B868E0003; Fri, 14 Jun 2019 02:36:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E15CD8E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:36:17 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id p16so209143wmi.8
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:36:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Th0UM04bEs+pDrLemn1eCiYRKTaHyYaaf8CfHkhXpEI=;
        b=rAk6b/f7SZ9NjfOo8sIRzOhKLjEJn+ZyWhKB7BfIbhN6y2E+mIOtRKFW+PfdwXNxOx
         pcoeokVmVf8yEt+U1Klf7gH9Wu2WSo3YcLzsgWir3eeWid3U6ewnfG4LvYwzqYzDchZp
         MBiSyFRp6Irjan5w8ucZl+8iTeAipra7qrsZQQzFgv0rWjblqp6pikArMtcm4M3ykyld
         BaX35LUU6ndF4Ohi6jtEBKTTI8R7VBKHUy0eSmtXDtttxi57Lb35UINQ3JGN2dprtkUw
         xe/3/tOwCQpOsGC0/PNkdd/AdnBn+epTX9R7V24pgtTS2H7NjBXMzPzxY/rUAnuWwC3X
         PhyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAU22/9cL4doloJxO2/VZGDOzDTlb9mYdTBVnoQzeqOvXHkh3Ku8
	jVGMGKkPKY8Ah0s6ePT78YcUzdtk1BiNpOM3fmvuHiLmT3t6nrZG/e9DOUvRJbRcbKneFBL/H9Y
	7u/VsDj5lUW7Ap2/BNzG2tU0795QQv9nUk1f3wjcx9qGAI7JnkXWyQquhmmygChMJqA==
X-Received: by 2002:a5d:4a8d:: with SMTP id o13mr28852945wrq.350.1560494177511;
        Thu, 13 Jun 2019 23:36:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgeeKuZyUZezywizUXLBg0Vsp21Hj2QMJhxxvV34xxmyc4korA6Zr0mA3nfWk4m4FYNaBm
X-Received: by 2002:a5d:4a8d:: with SMTP id o13mr28852891wrq.350.1560494176907;
        Thu, 13 Jun 2019 23:36:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560494176; cv=none;
        d=google.com; s=arc-20160816;
        b=0h6pI9DDt6oYOIu5xPN52mFkIlxaFjCJ4cA1KB/o/tAdVwb4lue2hZkvJJ2gQLIUU+
         h/vZR/z3co8mSe/HfsvdXhsnwQgFf7G5csrvg8PUtX05cb0F8Ef2j4Of8BlbscWulAxD
         jFV/cXZOEKZoIGTmuYKfFk3FTvZUQP4CPEsJIKCw5XvjvVpR8B8lEwPbk50d1ACz8m/o
         IfnqxcMa63Mg4ixQpWy+6XtzK+8cmg2m8ONF8w3/iWkIqujSR6CRvob/W9y9eg8cXoDy
         Aq/T4KK/8Bj5goARS0kW1inZTKRmnH2d6nLAMFHWxIOpTidf95gJ13m4ok/sdnLRdR9r
         3ZYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Th0UM04bEs+pDrLemn1eCiYRKTaHyYaaf8CfHkhXpEI=;
        b=0eXo6D35PWZFF8a1KnFaERUILp5IXRdKA9DVcD+uLxehjXYpX72L6iszrn/hR2bcsK
         khVERp7ruy4XouEQbphgjs7LSFQtqTggmD7NhiaX7K1/1hLZPzRhHKf0qprzgJwcNj94
         8KluWpWe6xW/rzmISldMWlp6wowDwXC30ApEa379o5ezNyut89blJF9fFxC3jP4gjaRy
         GG19kkywkKyjnxBk7oJeIfY3Q1zklrKIfp3gnxXySFcJBuQJ5Q1lulJJhPpIG7B0SVzk
         LForwWRUsMQKhstpxrbQmleHlXsCywL7Nej7NjA5kkIYAc8/Lg1hvkNqyw24hkMYXK5j
         d1jQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d7si1580915wrj.70.2019.06.13.23.36.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:36:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 50C3C68B02; Fri, 14 Jun 2019 08:35:49 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:35:49 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 13/22] device-dax: use the dev_pagemap internal refcount
Message-ID: <20190614063549.GK7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-14-hch@lst.de> <20190614002217.GB783@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614002217.GB783@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 05:22:17PM -0700, Ira Weiny wrote:
> > -	dev_dax->pgmap.ref = &dev_dax->ref;
> 
> I don't think this exactly correct.  pgmap.ref is a pointer to the dev_dax ref
> structure.  Taking it away will cause devm_memremap_pages() to fail AFAICS.
> 
> I think you need to change struct dev_pagemap as well:

Take a look at the previous patch, which adds an internal_ref field
to dev_pagemap that ->ref is set up to point to if not otherwise
initialized.


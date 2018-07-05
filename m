Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB676B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 04:29:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s21-v6so2942001edq.23
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 01:29:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s4-v6si5002185edj.431.2018.07.05.01.29.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 01:29:34 -0700 (PDT)
Date: Thu, 5 Jul 2018 10:29:31 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH 13/13] libnvdimm, namespace: Publish page structure init
 state / control
Message-ID: <20180705082931.echvdqipgvwhghf2@linux-x5ow.site>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153077341292.40830.11333232703318633087.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <153077341292.40830.11333232703318633087.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, Jeff Moyer <jmoyer@redhat.com>, hch@lst.de, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 04, 2018 at 11:50:13PM -0700, Dan Williams wrote:
> +static ssize_t memmap_state_store(struct device *dev,
> +		struct device_attribute *attr, const char *buf, size_t len)
> +{
> +	int i;
> +	struct nd_pfn *nd_pfn = to_nd_pfn_safe(dev);
> +	struct memmap_async_state *async = &nd_pfn->async;
> +
> +	if (strcmp(buf, "sync") == 0)
> +		/* pass */;
> +	else if (strcmp(buf, "sync\n") == 0)
> +		/* pass */;
> +	else
> +		return -EINVAL;

Hmm what about:

  	if (strncmp(buf, "sync", 4))
	   return -EINVAL;

This collapses 6 lines into 4.


-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850

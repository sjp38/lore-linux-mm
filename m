Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32B3B6B026F
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 04:19:01 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id bf1-v6so4105814plb.2
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 01:19:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w123-v6si8021781pfb.362.2018.07.06.01.18.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 01:19:00 -0700 (PDT)
Date: Fri, 6 Jul 2018 10:18:56 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH 13/13] libnvdimm, namespace: Publish page structure init
 state / control
Message-ID: <20180706081856.uj4jozwxahibrmui@linux-x5ow.site>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153077341292.40830.11333232703318633087.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180705082931.echvdqipgvwhghf2@linux-x5ow.site>
 <CAPcyv4h1L6ZMCqWXhWD_ZJ=sH7SVzuUGMG2Ln=6Cy6sR4S=VUw@mail.gmail.com>
 <20180705144941.drfiwhqcnqqorqu3@linux-x5ow.site>
 <20180705132455.2a40de08dbe3a9bb384fb870@linux-foundation.org>
 <CAPcyv4h973nANXOUFe9rE7pn0tKxy=Csh=XYsyA6V_bPF0eRAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4h973nANXOUFe9rE7pn0tKxy=Csh=XYsyA6V_bPF0eRAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, Jeff Moyer <jmoyer@redhat.com>, Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 05, 2018 at 01:34:01PM -0700, Dan Williams wrote:
> >
> > sysfs_streq()
> 
> Nice... /me stares down a long list of needed cleanups in the
> libnvdimm sysfs implementation with that gem.

Cool. I think not only libnvdimm would profit from this. /me looks
into scsi and nvme now.

-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850

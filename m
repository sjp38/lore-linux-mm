Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFB296B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 16:24:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q21-v6so5562130pff.4
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 13:24:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d3-v6si6680104pla.28.2018.07.05.13.24.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 13:24:56 -0700 (PDT)
Date: Thu, 5 Jul 2018 13:24:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 13/13] libnvdimm, namespace: Publish page structure init
 state / control
Message-Id: <20180705132455.2a40de08dbe3a9bb384fb870@linux-foundation.org>
In-Reply-To: <20180705144941.drfiwhqcnqqorqu3@linux-x5ow.site>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
	<153077341292.40830.11333232703318633087.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20180705082931.echvdqipgvwhghf2@linux-x5ow.site>
	<CAPcyv4h1L6ZMCqWXhWD_ZJ=sH7SVzuUGMG2Ln=6Cy6sR4S=VUw@mail.gmail.com>
	<20180705144941.drfiwhqcnqqorqu3@linux-x5ow.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, Jeff Moyer <jmoyer@redhat.com>, Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 5 Jul 2018 16:49:41 +0200 Johannes Thumshirn <jthumshirn@suse.de> wrote:

> On Thu, Jul 05, 2018 at 07:46:05AM -0700, Dan Williams wrote:
> > ...but that also allows 'echo "syncAndThenSomeGarbage" >
> > /sys/.../memmap_state' to succeed.
> 
> Yep it does :-(.
> 
> Damn

sysfs_streq()

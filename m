Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1448E6B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 16:34:03 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w204-v6so9144098oib.9
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 13:34:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c184-v6sor4787618oih.272.2018.07.05.13.34.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 13:34:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180705132455.2a40de08dbe3a9bb384fb870@linux-foundation.org>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153077341292.40830.11333232703318633087.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180705082931.echvdqipgvwhghf2@linux-x5ow.site> <CAPcyv4h1L6ZMCqWXhWD_ZJ=sH7SVzuUGMG2Ln=6Cy6sR4S=VUw@mail.gmail.com>
 <20180705144941.drfiwhqcnqqorqu3@linux-x5ow.site> <20180705132455.2a40de08dbe3a9bb384fb870@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 5 Jul 2018 13:34:01 -0700
Message-ID: <CAPcyv4h973nANXOUFe9rE7pn0tKxy=Csh=XYsyA6V_bPF0eRAw@mail.gmail.com>
Subject: Re: [PATCH 13/13] libnvdimm, namespace: Publish page structure init
 state / control
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Thumshirn <jthumshirn@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, Jeff Moyer <jmoyer@redhat.com>, Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 5, 2018 at 1:24 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 5 Jul 2018 16:49:41 +0200 Johannes Thumshirn <jthumshirn@suse.de> wrote:
>
>> On Thu, Jul 05, 2018 at 07:46:05AM -0700, Dan Williams wrote:
>> > ...but that also allows 'echo "syncAndThenSomeGarbage" >
>> > /sys/.../memmap_state' to succeed.
>>
>> Yep it does :-(.
>>
>> Damn
>
> sysfs_streq()

Nice... /me stares down a long list of needed cleanups in the
libnvdimm sysfs implementation with that gem.

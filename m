Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCCC6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 17:21:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v66so47296304wrc.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:21:12 -0700 (PDT)
Received: from cloudserver094114.home.net.pl (cloudserver094114.home.net.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id d124si12393151wmc.55.2017.03.13.14.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 Mar 2017 14:21:10 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 1/2] mm: add private lock to serialize memory hotplug operations
Date: Mon, 13 Mar 2017 22:15:46 +0100
Message-ID: <5904743.94GiNAKfGi@aspire.rjw.lan>
In-Reply-To: <CAPcyv4i1phF5rZL--g6ojguHScKetNA3gfsZRpHhVw3VbgqmFg@mail.gmail.com>
References: <20170309130616.51286-1-heiko.carstens@de.ibm.com> <20170313185710.GA3422@osiris> <CAPcyv4i1phF5rZL--g6ojguHScKetNA3gfsZRpHhVw3VbgqmFg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Monday, March 13, 2017 12:44:25 PM Dan Williams wrote:
> On Mon, Mar 13, 2017 at 11:57 AM, Heiko Carstens
> <heiko.carstens@de.ibm.com> wrote:
> > On Thu, Mar 09, 2017 at 11:34:44PM +0100, Rafael J. Wysocki wrote:
> >> > The memory described by devm_memremap_pages() is never "onlined" to
> >> > the core mm. We're only using arch_add_memory() to get a linear
> >> > mapping and page structures. The rest of memory hotplug is skipped,
> >> > and this ZONE_DEVICE memory is otherwise hidden from the core mm.
> >>
> >> OK, that should be fine then.
> >
> > So, does that mean that the patch is ok as it is? If so, it would be good
> > to get an Ack from both, you and Dan, please.
> 
> Acked-by: Dan Williams <dan.j.williams@intel.com>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

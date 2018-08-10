Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A6ACA6B0006
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 09:00:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f8-v6so3289535eds.6
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 06:00:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i17-v6si2028021edg.204.2018.08.10.06.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 06:00:57 -0700 (PDT)
Date: Fri, 10 Aug 2018 15:00:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] resource: Merge resources on a node when hot-adding
 memory
Message-ID: <20180810130052.GC1644@dhcp22.suse.cz>
References: <20180809025409.31552-1-rashmica.g@gmail.com>
 <20180809181224.0b7417e51215565dbda9f665@linux-foundation.org>
 <CAC6rBs=yYYZw-c02yp6rx-+TN2oUGgrp=uuLhZ=Kc_nnjmTRqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAC6rBs=yYYZw-c02yp6rx-+TN2oUGgrp=uuLhZ=Kc_nnjmTRqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashmica Gupta <rashmica.g@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, toshi.kani@hpe.com, tglx@linutronix.de, bp@suse.de, brijesh.singh@amd.com, thomas.lendacky@amd.com, jglisse@redhat.com, gregkh@linuxfoundation.org, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, Vlastimil Babka <vbabka@suse.cz>, malat@debian.org, Bjorn Helgaas <bhelgaas@google.com>, osalvador@techadventures.net, yasu.isimatu@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Fri 10-08-18 16:55:40, Rashmica Gupta wrote:
[...]
> Most memory hotplug/hotremove seems to be block or section based, and
> always adds and removes memory at the same place.

Yes and that is hard wired to the memory hotplug code. It is not easy to
make it work outside of section units restriction. So whatever your
memtrace is doing and if it relies on subsection hotplug it cannot
possibly work with the current code.

I didn't get to review your patch but if it is only needed for an
unmerged code I would rather incline to not merge it unless it is a
clear win to the resource subsystem. A report from Oscar shows that this
is not the case though.

-- 
Michal Hocko
SUSE Labs

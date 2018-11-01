Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB5E76B0005
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 05:58:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i1-v6so9605741edc.1
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 02:58:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1-v6si8167985eje.142.2018.11.01.02.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 02:58:36 -0700 (PDT)
Date: Thu, 1 Nov 2018 10:58:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug failed to offline on bare metal system of
 multiple nodes
Message-ID: <20181101095834.GD23921@dhcp22.suse.cz>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
 <20181101092212.GB23921@dhcp22.suse.cz>
 <20181101094243.GD14493@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101094243.GD14493@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 01-11-18 17:42:43, Baoquan He wrote:
> On 11/01/18 at 10:22am, Michal Hocko wrote:
> > > I haven't figured out why the above commit caused those memmory
> > > block in MOVABL zone being not removable. Still checking. Attach the
> > > tested reverting patch in this mail.
> > 
> > Could you check which of the test inside has_unmovable_pages claimed the
> > failure? Going back to marking movable_zone as guaranteed to offline is
> > just too fragile.
> 
> Sure, will add debugging code and check. Will update if anything found.

Please dump the whole struct page state for the failing pfn.
-- 
Michal Hocko
SUSE Labs

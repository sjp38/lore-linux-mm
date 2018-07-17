Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF42C6B0273
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 10:28:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y17-v6so649995eds.22
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:28:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t27-v6si1106598edd.157.2018.07.17.07.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 07:28:29 -0700 (PDT)
Date: Tue, 17 Jul 2018 16:28:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Deprecate kernelcore=nn and movable_core=
Message-ID: <20180717142828.GK7193@dhcp22.suse.cz>
References: <20180717131837.18411-1-bhe@redhat.com>
 <20180717133109.GI7193@dhcp22.suse.cz>
 <20180717142443.GG1724@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717142443.GG1724@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, corbet@lwn.net, linux-doc@vger.kernel.org

On Tue 17-07-18 22:24:43, Baoquan He wrote:
> Hi Michal,
> 
> On 07/17/18 at 03:31pm, Michal Hocko wrote:
> > On Tue 17-07-18 21:18:37, Baoquan He wrote:
> > > We can still use 'kernelcore=mirror' or 'movable_node' for the usage
> > > of hotplug and movable zone. If somebody shows up with a valid usecase
> > > we can reconsider.
> > 
> > Well this doesn't really explain why to deprecate this functionality.
> > It is a rather ugly hack that has been originally introduced for large
> > order allocations. But we do have compaction these days. Even though the
> > compaction cannot solve all the fragmentation issues the zone movable is
> > not a great answer as it introduces other issues (basically highmem kind
> > of issues we used to have on 32b systems).
> > The current code doesn't work with KASLR and the code is too subtle to
> > work properly in other cases as well. E.g. movablecore range might cover
> > already used memory (e.g. bootmem allocations) and therefore it doesn't
> > comply with the basic assumption that the memory is movable and that
> > confuses memory hotplug (e.g. 15c30bc09085 ("mm, memory_hotplug: make
> > has_unmovable_pages more robust").
> > 
> > There are probably other issues I am not aware of but primarily the code
> > adds a maintenance burden which would be better to get rid of.
> > 
> > I would also go further and remove all the code the feature is using at
> > one go. If somebody really needs this functionality we would need to
> > revert the whole thing anyway.
> 
> Thanks for these details. I can arrange your above saying and rewrite
> patch log. Are you suggesting removing the code "kernelcore=nn" and
> "movablecore=" are using? If yes, I can repost with these changes.

Yes.
-- 
Michal Hocko
SUSE Labs

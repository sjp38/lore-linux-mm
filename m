Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F62D6B0033
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:40:52 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m190so1586847pgm.4
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:40:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12-v6si5885455plr.131.2018.04.13.06.40.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 06:40:51 -0700 (PDT)
Date: Fri, 13 Apr 2018 15:40:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 2/8] mm: introduce PG_offline
Message-ID: <20180413134047.GR17484@dhcp22.suse.cz>
References: <20180413131632.1413-1-david@redhat.com>
 <20180413131632.1413-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413131632.1413-3-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, James Hogan <jhogan@kernel.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, open list <linux-kernel@vger.kernel.org>

On Fri 13-04-18 15:16:26, David Hildenbrand wrote:
> online_pages()/offline_pages() theoretically allows us to work on
> sub-section sizes. This is especially relevant in the context of
> virtualization. It e.g. allows us to add/remove memory to Linux in a VM in
> 4MB chunks.

Well, theoretically possible but this would require a lot of auditing
because the hotplug and per section assumption is quite a spread one.

> While the whole section is marked as online/offline, we have to know
> the state of each page. E.g. to not read memory that is not online
> during kexec() or to properly mark a section as offline as soon as all
> contained pages are offline.

But you cannot use a page flag for that, I am afraid. Page flags are
extremely scarce resource. I haven't looked at the rest of the series
but _if_ we have a bit spare which I am not really sure about then you
should prove there are no other ways around this.
 
> Signed-off-by: David Hildenbrand <david@redhat.com>
-- 
Michal Hocko
SUSE Labs

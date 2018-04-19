Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ECB5B6B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 03:33:26 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 88-v6so2991025wrc.21
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 00:33:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u26si1630902edl.251.2018.04.19.00.33.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 00:33:25 -0700 (PDT)
Date: Thu, 19 Apr 2018 09:33:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180419073323.GO17484@dhcp22.suse.cz>
References: <20180413131632.1413-1-david@redhat.com>
 <20180413155917.GX17484@dhcp22.suse.cz>
 <b51ca7a1-c5ae-fbbb-8edf-e71f383da07e@redhat.com>
 <20180416140810.GR17484@dhcp22.suse.cz>
 <d39f5b5d-db9b-0729-e68b-b15c314ddd13@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d39f5b5d-db9b-0729-e68b-b15c314ddd13@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org

On Wed 18-04-18 17:46:25, David Hildenbrand wrote:
[...]
> BTW I was able to easily produce the case where do_migrate_range() would
> loop for ever (well at least for multiple minutes, but I assume this
> would have went on :) )

I am definitely interested to hear details.

-- 
Michal Hocko
SUSE Labs

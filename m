Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4508C6B4D65
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:25:55 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b7so12573231eda.10
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 06:25:55 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c20si4087226eda.11.2018.11.28.06.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 06:25:54 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 28 Nov 2018 15:25:53 +0100
From: osalvador@suse.de
Subject: Re: [PATCH v2 3/5] mm, memory_hotplug: Move zone/pages handling to
 offline stage
In-Reply-To: <20181128075238.GD14414@rapoport-lnx>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-4-osalvador@suse.de>
 <20181128075238.GD14414@rapoport-lnx>
Message-ID: <d93d2e984b9d02a47af6e030d2862102@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>

>>  /**
>> - * __remove_pages() - remove sections of pages from a zone
>> - * @zone: zone from which pages need to be removed
>> + * __remove_pages() - remove sections of pages from a nid
>> + * @nid: nid from which pages belong to
> 
> Nit: the description sounds a bit awkward.
> Why not to keep the original one with s/zone/node/?

Yes, much better.

thanks

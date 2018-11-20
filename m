Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 91D6C6B204D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:25:19 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x98-v6so1370483ede.0
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:25:19 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c23si2997149edv.143.2018.11.20.06.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:25:18 -0800 (PST)
Date: Tue, 20 Nov 2018 15:25:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, memory_hotplug: try to migrate full section
 worth of pages
Message-ID: <20181120142517.GL22247@dhcp22.suse.cz>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-2-mhocko@kernel.org>
 <65271adc-93b4-19fc-e54b-11db582359c5@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65271adc-93b4-19fc-e54b-11db582359c5@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 20-11-18 15:18:41, David Hildenbrand wrote:
[...]
> (we could also check for pending signals inside that function if really
> required)

do_migrate_pages is not the proper layer to check signals. Because the
loop only isolates pages and that is not expensive. The most expensive
part is deeper down in the migration core. We wait for page lock or
writeback and that can take a long. None of that is killable wait which
is a larger surgery but something that we should consider should there
be any need to address this.

> Reviewed-by: David Hildenbrand <david@redhat.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

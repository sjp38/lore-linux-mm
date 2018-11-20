Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1B706B204D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:52:07 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so1343095edm.18
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:52:07 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id e16-v6si4455067ejk.23.2018.11.20.06.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:52:06 -0800 (PST)
Message-ID: <1542725492.6817.3.camel@suse.com>
Subject: Re: [RFC PATCH 1/3] mm, memory_hotplug: try to migrate full section
 worth of pages
From: osalvador <osalvador@suse.com>
Date: Tue, 20 Nov 2018 15:51:32 +0100
In-Reply-To: <20181120134323.13007-2-mhocko@kernel.org>
References: <20181120134323.13007-1-mhocko@kernel.org>
	 <20181120134323.13007-2-mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 2018-11-20 at 14:43 +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> do_migrate_range has been limiting the number of pages to migrate to
> 256
> for some reason which is not documented. 

When looking back at old memory-hotplug commits one feels pretty sad
about the brevity of the changelogs.

> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

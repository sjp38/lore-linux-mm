Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 87C528E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 05:05:57 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d41so15608260eda.12
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 02:05:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l25si3319511edd.87.2018.12.19.02.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 02:05:56 -0800 (PST)
Date: Wed, 19 Dec 2018 11:05:55 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181219100555.GD5758@dhcp22.suse.cz>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218204656.4297-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Wed 19-12-18 04:46:56, Wei Yang wrote:
[...]
> Since drain_all_pages() is zone based, by reduce times of
> drain_all_pages() also reduce some contention on this particular zone.

I forgot to add. As said before this is a really weak justification. If
there is really some contention then I would like to see some numbers
backing that claim.

A proper justification would be that reallying on draining in callers
just sucks. As we can see we are doing that suboptimally based on a weak
understanding of the functionality. So it makes sense to remove that
draining and rely on the isolation code do the right thing. Then it is a
clear cleanup.
-- 
Michal Hocko
SUSE Labs

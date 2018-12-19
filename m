Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1CA8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 09:39:30 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so16698218edc.9
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 06:39:29 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r53si987557eda.218.2018.12.19.06.39.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 06:39:28 -0800 (PST)
Date: Wed, 19 Dec 2018 15:39:27 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181219143927.GO5758@dhcp22.suse.cz>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181219095110.GB5758@dhcp22.suse.cz>
 <20181219095715.73x6hvmndyku2rec@d104.suse.de>
 <20181219135307.bjd6rckseczpfeae@master>
 <20181219141343.GN5758@dhcp22.suse.cz>
 <20181219143327.wdsufbn2oh6ygnne@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219143327.wdsufbn2oh6ygnne@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, david@redhat.com

On Wed 19-12-18 14:33:27, Wei Yang wrote:
[...]
> Then I am confused about the objection to this patch. Finally, we drain
> all the pages in pcp list and the range is isolated.

Please read my emails more carefully. As I've said, the only reason to
do care about draining is to remove it from where it doesn't belong.

-- 
Michal Hocko
SUSE Labs

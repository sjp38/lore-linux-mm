Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 107786B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:45:15 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so1961880wmd.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:45:15 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id q206si19386927wme.25.2017.01.18.01.45.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 01:45:14 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 9ECCA990A8
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 09:45:13 +0000 (UTC)
Date: Wed, 18 Jan 2017 09:45:13 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 1/4] mm, page_alloc: fix check for NULL preferred_zone
Message-ID: <20170118094513.v6nlnpwnfl6pnkiv@techsingularity.net>
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-2-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170117221610.22505-2-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ganapatrao Kulkarni <gpkulkarni@gmail.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 17, 2017 at 11:16:07PM +0100, Vlastimil Babka wrote:
> Since commit c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in
> a zonelist twice") we have a wrong check for NULL preferred_zone, which can
> theoretically happen due to concurrent cpuset modification. We check the
> zoneref pointer which is never NULL and we should check the zone pointer.
> 
> Fixes: c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in a zonelist twice")
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

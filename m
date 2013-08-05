Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id BE7CE6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 04:59:24 -0400 (EDT)
Date: Mon, 5 Aug 2013 10:59:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] mm, page_alloc: add likely macro to help compiler
 optimization
Message-ID: <20130805085922.GE10146@dhcp22.suse.cz>
References: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20130802162722.GA29220@dhcp22.suse.cz>
 <20130802204710.GX715@cmpxchg.org>
 <20130802213607.GA4742@dhcp22.suse.cz>
 <20130805081008.GF27240@lge.com>
 <20130805085041.GG27240@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130805085041.GG27240@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Mon 05-08-13 17:50:41, Joonsoo Kim wrote:
[...]
> IMHO, although there is no effect, it is better to add likely macro,
> because arrangement can be changed from time to time without any
> consideration of assembly code generation. How about your opinion,
> Johannes and Michal?

This is a matter of taste. I do not like new *likely annotations if they
do not make difference. But no strong objections if others like it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

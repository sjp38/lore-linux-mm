Message-ID: <46A457F8.7090005@yahoo.com.au>
Date: Mon, 23 Jul 2007 17:25:44 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] zone config patch set [2/2] CONFIG_ZONE_MOVABLE
References: <20070721160049.75bc8d9f.kamezawa.hiroyu@jp.fujitsu.com> <20070721160336.28ec3ad8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070721160336.28ec3ad8.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "apw@shadowen.org" <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Makes ZONE_MOVABLE as configurable
> 
> Based on "zone_ifdef_cleanup_by_renumbering.patch"
> 
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Great, thanks. IMO this should definitely go in before 2.6.23.


-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 0DA4E6B0033
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 11:52:01 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld11so367314pab.22
        for <linux-mm@kvack.org>; Wed, 03 Jul 2013 08:52:01 -0700 (PDT)
Message-ID: <51D44890.4080003@gmail.com>
Date: Wed, 03 Jul 2013 23:51:44 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] Support multiple pages allocation
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com> <20130703152824.GB30267@dhcp22.suse.cz>
In-Reply-To: <20130703152824.GB30267@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On 07/03/2013 11:28 PM, Michal Hocko wrote:
> On Wed 03-07-13 17:34:15, Joonsoo Kim wrote:
> [...]
>> For one page allocation at once, this patchset makes allocator slower than
>> before (-5%). 
> 
> Slowing down the most used path is a no-go. Where does this slow down
> come from?

I guess, it might be: for one page allocation at once, comparing to the original
code, this patch adds two parameters nr_pages and pages and will do extra checks
for the parameter nr_pages in the allocation path.

> 
> [...]


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

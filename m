Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B7F8F6B025E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 07:44:18 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id p65so229836895wmp.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 04:44:18 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id v124si20577877wmg.0.2016.03.23.04.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 04:44:17 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 5829A1C1692
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 11:44:17 +0000 (GMT)
Date: Wed, 23 Mar 2016 11:44:15 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 4/5] mm/lru: is_file/active_lru can be boolean
Message-ID: <20160323114415.GJ31585@techsingularity.net>
References: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <1458699969-3432-5-git-send-email-baiyaowei@cmss.chinamobile.com>
 <1458703028.22080.7.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1458703028.22080.7.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, rientjes@google.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, kuleshovmail@gmail.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 22, 2016 at 08:17:08PM -0700, Joe Perches wrote:
> On Wed, 2016-03-23 at 10:26 +0800, Yaowei Bai wrote:
> > This patch makes is_file/active_lru return bool to improve
> > readability due to these particular functions only using either
> > one or zero as their return value.
> > 
> > No functional change.
> 
> These assignments to int should likely be modified too
> 

Which would lead to oddities as the ints are used as offsets within
enums. Patch 2 has a problem where a bool is then used as part of a
bitmask operation.

I stopped looking fairly early on. Conversions from int to bool as part
of a cleanup-only series are almost never useful and sometimes introduce
subtle breakage. It is only worth the conversion when the helper is being
modified for some other purpose.

On that grounds, NAK to the whole series as small problems were quickly
obvious and it's not worth the brainpower to find all the problems when
the end result does not give us a tangible improvement.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

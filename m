Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 929966B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 09:15:50 -0500 (EST)
Received: by wmec201 with SMTP id c201so66908728wme.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 06:15:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rz9si18824466wjb.38.2015.12.04.06.15.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Dec 2015 06:15:48 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
References: <20151125143010.GI27283@dhcp22.suse.cz>
 <1448899821-9671-1-git-send-email-vbabka@suse.cz>
 <4EAD2C33-D0E4-4DEB-92E5-9C0457E8635C@gmail.com> <565F5CD9.9080301@suse.cz>
 <1F60C207-1CC2-4B28-89AC-58C72D95A39D@gmail.com>
 <87a8psq7r6.fsf@rasmusvillemoes.dk>
 <89A4C9BC-47F6-4768-8AA8-C1C4EFEFC52D@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5661A011.2010400@suse.cz>
Date: Fri, 4 Dec 2015 15:15:45 +0100
MIME-Version: 1.0
In-Reply-To: <89A4C9BC-47F6-4768-8AA8-C1C4EFEFC52D@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On 12/03/2015 07:38 PM, yalin wang wrote:
> thata??s all, see cpumask_pr_args(masks) macro,
> it also use macro and  %*pb  to print cpu mask .
> i think this method is not very complex to use .

Well, one also has to write the appropriate translation tables.

> search source code ,
> there is lots of printk to print flag into hex number :
> $ grep -n  -r 'printk.*flag.*%xa??  .
> it will be great if this flag string print is generic.

I think it can always be done later, this is an internal API. For now we 
just have 3 quite generic flags, so let's not over-engineer things right 
now.

> Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

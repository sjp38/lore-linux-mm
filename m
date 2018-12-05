Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E22ED6B7403
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 06:15:16 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e12so9682723edd.16
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 03:15:16 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id d12si2597087edh.283.2018.12.05.03.15.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 03:15:15 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id EE3C0B889A
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:15:14 +0000 (GMT)
Date: Wed, 5 Dec 2018 11:15:13 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm, pageblock: make sure pageblock won't exceed
 mem_sectioin
Message-ID: <20181205111513.GA23260@techsingularity.net>
References: <20181205091905.27727-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181205091905.27727-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Wed, Dec 05, 2018 at 05:19:04PM +0800, Wei Yang wrote:
> When SPARSEMEM is used, there is an indication that pageblock is not
> allowed to exceed one mem_section. Current code doesn't have this
> constrain explicitly.
> 
> This patch adds this to make sure it won't.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Is this even possible? This would imply that the section size is smaller
than max order which would be quite a crazy selection for a sparesemem
section size. A lot of assumptions on the validity of PFNs within a
max-order boundary would be broken with such a section size. I'd be
surprised if such a setup could even boot, let alone run.

-- 
Mel Gorman
SUSE Labs

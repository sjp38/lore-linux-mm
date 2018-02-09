Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF5656B0005
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 19:12:56 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g65so3102461wmf.7
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 16:12:56 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id y6si741025wrh.446.2018.02.08.16.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 16:12:54 -0800 (PST)
Date: Fri, 9 Feb 2018 01:12:41 +0100
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: [PATCH v3 1/1] mm: page_alloc: skip over regions of invalid pfns
 on UMA
Message-ID: <20180209001241.GA28668@vmlxhi-102.adit-jv.com>
References: <20180124143545.31963-1-erosca@de.adit-jv.com>
 <20180124143545.31963-2-erosca@de.adit-jv.com>
 <20180129184746.GK21609@dhcp22.suse.cz>
 <20180203122422.GA11832@vmlxhi-102.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180203122422.GA11832@vmlxhi-102.adit-jv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eugeniu Rosca <erosca@de.adit-jv.com>

Hello linux-mm community,

Everyone of you might have and probably do have more important tasks in
their queue, compared to the boot optimization discussed in this email
chain.

Still, this patch is important for our organization, our community and
our suppliers. So, I still hope that we will be able to move forward
with it somehow, especially because it has received positive feedback
from Matthew Wilcox and Pavel Tatashin. Michal Hocko suggested that a
previous version of this patch might be more appropriate due to its
simplicity and slightly better readability.

Many thanks for your participation so far.

Best regards,
Eugeniu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

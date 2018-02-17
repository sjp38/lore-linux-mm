Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 497776B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 19:43:33 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 137so2949542wml.0
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 16:43:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 4si10512913wma.257.2018.02.16.16.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 16:43:31 -0800 (PST)
Date: Fri, 16 Feb 2018 16:43:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 1/1] mm: page_alloc: skip over regions of invalid
 pfns on UMA
Message-Id: <20180216164328.de7d37584409e827c396bf69@linux-foundation.org>
In-Reply-To: <20180212184759.GI3443@dhcp22.suse.cz>
References: <20180124143545.31963-1-erosca@de.adit-jv.com>
	<20180124143545.31963-2-erosca@de.adit-jv.com>
	<20180129184746.GK21609@dhcp22.suse.cz>
	<20180203122422.GA11832@vmlxhi-102.adit-jv.com>
	<20180212150314.GG3443@dhcp22.suse.cz>
	<20180212161640.GA30811@vmlxhi-102.adit-jv.com>
	<20180212184759.GI3443@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Eugeniu Rosca <erosca@de.adit-jv.com>, Matthew Wilcox <willy@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 12 Feb 2018 19:47:59 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > prerequisite for this is to reach some agreement on what people think is
> > the best option, which I feel didn't occur yet.
> 
> I do not have a _strong_ preference here as well. So I will leave the
> decision to you.
> 
> In any case feel free to add
> Acked-by: Michal Hocko <mhocko@suse.com>

I find Michal's version to be a little tidier.

Eugeniu, please send Michal's patch at me with a fresh changelog, with
your signed-off-by and your tested-by and your reported-by and we may
as well add Michal's (thus-far-missing) signed-off-by ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

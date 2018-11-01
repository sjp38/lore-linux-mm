Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA8A06B0271
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 06:27:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g26-v6so12305759edp.13
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 03:27:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7-v6si1638802eda.362.2018.11.01.03.27.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 03:27:35 -0700 (PDT)
Date: Thu, 1 Nov 2018 11:27:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/page_owner: use kvmalloc instead of kmalloc
Message-ID: <20181101102734.GF23921@dhcp22.suse.cz>
References: <20181029081706.GC32673@dhcp22.suse.cz>
 <1540862950.12374.40.camel@mtkswgap22>
 <20181030060601.GR32673@dhcp22.suse.cz>
 <1540882551.23278.12.camel@mtkswgap22>
 <20181030081537.GV32673@dhcp22.suse.cz>
 <1540975637.10275.10.camel@mtkswgap22>
 <20181031101501.GL32673@dhcp22.suse.cz>
 <1540981182.16084.1.camel@mtkswgap22>
 <20181031114107.GM32673@dhcp22.suse.cz>
 <1541066412.31492.10.camel@mtkswgap22>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541066412.31492.10.camel@mtkswgap22>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com

On Thu 01-11-18 18:00:12, Miles Chen wrote:
[...]
> I did a test today, the only code changed is to clamp to read count to
> PAGE_SIZE and it worked well. Maybe we can solve this issue by just
> clamping the read count.
> 
> count = count > PAGE_SIZE ? PAGE_SIZE : count;

This i what Matthew was proposing AFAIR. At least as a stop gap
solution. Maybe we want to extend this to a more standard implementation
later on (e.g. seq_file).
-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A00B06B04D1
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 04:15:41 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a16-v6so8588080plm.7
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 01:15:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g8-v6si6394305pli.13.2018.10.30.01.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 01:15:40 -0700 (PDT)
Date: Tue, 30 Oct 2018 09:15:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/page_owner: use kvmalloc instead of kmalloc
Message-ID: <20181030081537.GV32673@dhcp22.suse.cz>
References: <1540790176-32339-1-git-send-email-miles.chen@mediatek.com>
 <20181029080708.GA32673@dhcp22.suse.cz>
 <20181029081706.GC32673@dhcp22.suse.cz>
 <1540862950.12374.40.camel@mtkswgap22>
 <20181030060601.GR32673@dhcp22.suse.cz>
 <1540882551.23278.12.camel@mtkswgap22>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540882551.23278.12.camel@mtkswgap22>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com

On Tue 30-10-18 14:55:51, Miles Chen wrote:
[...]
> It's a real problem when using page_owner.
> I found this issue recently: I'm not able to read page_owner information
> during a overnight test. (error: read failed: Out of memory). I replace
> kmalloc() with vmalloc() and it worked well.

Is this with trimming the allocation to a single page and doing shorter
than requested reads?
-- 
Michal Hocko
SUSE Labs

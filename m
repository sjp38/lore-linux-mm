Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA976B025F
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 09:49:37 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id j12so37469054lbo.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 06:49:37 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id n125si57204377wmn.11.2016.06.03.06.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 06:49:36 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id a136so23835229wme.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 06:49:36 -0700 (PDT)
Date: Fri, 3 Jun 2016 15:49:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160603134934.GJ20676@dhcp22.suse.cz>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <20160602092113.GH1995@dhcp22.suse.cz>
 <20160603071551.GA453@swordfish>
 <20160603072536.GB20676@dhcp22.suse.cz>
 <20160603084347.GA502@swordfish>
 <20160603095549.GD20676@dhcp22.suse.cz>
 <20160603100505.GE20676@dhcp22.suse.cz>
 <20160603133813.GA578@swordfish>
 <20160603134509.GI20676@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160603134509.GI20676@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 03-06-16 15:45:09, Michal Hocko wrote:
> On Fri 03-06-16 22:38:13, Sergey Senozhatsky wrote:
> [...]
> > Michal, I'll try to test during the weekend (away from the affected box
> > now), but in the worst case it can as late as next Thursday (gonna travel
> > next week).
> 
> No problem. I would really like to hear from Andrea before we give this
> a serious try anyway.

And just for an easier review, here is what I have right now:
---

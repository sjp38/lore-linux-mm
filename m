Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F02B6B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 09:08:41 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id n3so43038950wjy.6
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 06:08:41 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id kr2si62279838wjc.288.2016.12.30.06.08.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Dec 2016 06:08:40 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id CFBBA1C1398
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 14:08:39 +0000 (GMT)
Date: Fri, 30 Dec 2016 14:08:39 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161230140839.qg3maz4ifyf7nwgq@techsingularity.net>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
 <20161230123620.jcuquzof3bpxomdn@techsingularity.net>
 <20161230125615.GH13301@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161230125615.GH13301@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 30, 2016 at 01:56:16PM +0100, Michal Hocko wrote:
> On Fri 30-12-16 12:36:20, Mel Gorman wrote:
> [...]
> > I'll neither ack nor nak this patch. However, I would much prefer an
> > additional option be added to sysfs called defer-fault that would avoid
> > all fault-based stalls but still potentially stall for MADV_HUGEPAGE.
> 
> Would you consider changing the semantic of defer=madvise to invoke
> KSWAPD for !madvised vmas as acceptable. It would be a change in
> semantic but I am wondering what would be a risk and potential
> regression space.
> 

I'd worry a little, but not a lot. The concern would be that kswapd waking
up would reclaim pages and cause major faults that would have remained
resident with the current semantics.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

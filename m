Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF9A6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 16:53:19 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id z128so42695373pfb.4
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 13:53:19 -0800 (PST)
Received: from mail-pg0-x22b.google.com (mail-pg0-x22b.google.com. [2607:f8b0:400e:c05::22b])
        by mx.google.com with ESMTPS id d85si73695358pfb.163.2017.01.04.13.53.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 13:53:18 -0800 (PST)
Received: by mail-pg0-x22b.google.com with SMTP id y62so179600390pgy.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 13:53:18 -0800 (PST)
Date: Wed, 4 Jan 2017 13:53:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
In-Reply-To: <20170104101218.x7c5pwf65psy2l52@techsingularity.net>
Message-ID: <alpine.DEB.2.10.1701041348580.77987@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com> <20161222100009.GA6055@dhcp22.suse.cz> <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com> <20161230123620.jcuquzof3bpxomdn@techsingularity.net>
 <alpine.DEB.2.10.1612301412390.85559@chino.kir.corp.google.com> <20170103103749.fjj6uf27wuqvbnta@techsingularity.net> <alpine.DEB.2.10.1701031334020.131960@chino.kir.corp.google.com> <20170104101218.x7c5pwf65psy2l52@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 4 Jan 2017, Mel Gorman wrote:

> There is a slight disconnect. The bug reports I'm aware of predate the
> introduction of "defer" and the current "madvise" semantics for defrag. The
> current semantics have not had enough time in the field to generate
> reports. I expect lag before users are aware of "defer" due to the number
> of recommendations out there about blindly disabling THP.  This because
> the majority of users I deal with are not running mainline kernels.
> 

I find it sad that we need to have five options for thp defrag and that 
people now need to research options that don't break their userspace and 
affect all applications on the system, especially when one of those 
options now appears to have a hypothetical usecase, but in the interest of 
making forward progress in this area for support that we truly need, I'll 
reluctantly propose it as a patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

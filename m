Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 613B1828DF
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 16:46:56 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id x65so53592931pfb.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:46:56 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id c10si22366316pat.170.2016.02.12.13.46.55
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 13:46:55 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <20160128235815.GA5953@cmpxchg.org>
 <56AABA79.3030103@cisco.com> <56AAC085.9060509@cisco.com>
 <20160129015534.GA6401@cmpxchg.org> <56ABEAA7.1020706@redhat.com>
 <D2DE3289.2B1F3%khalidm@cisco.com> <56BB7BC7.4040403@cisco.com>
 <56BB7DDE.8080206@intel.com> <56BB8B5E.0@cisco.com>
 <1455228719.15821.18.camel@redhat.com> <D2E35753.2BB9D%khalidm@cisco.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56BE52CE.5070403@intel.com>
Date: Fri, 12 Feb 2016 13:46:54 -0800
MIME-Version: 1.0
In-Reply-To: <D2E35753.2BB9D%khalidm@cisco.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Khalid Mughal (khalidm)" <khalidm@cisco.com>, Rik van Riel <riel@redhat.com>, "Daniel Walker (danielwa)" <danielwa@cisco.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

On 02/12/2016 10:01 AM, Khalid Mughal (khalidm) wrote:
> If you look at the attached pdf, you will notice that OOM messages start
> to appear when memAvailable is showing 253MB (259228 KB) Free, memFree is
> 13.5MB (14008 KB) Free, and dropcache based calculation 3Available memory2
> is showing 21MB (21720 KB) Free.
> 
> So, it appears that memAvailable is not as accurate, especially if data is
> used to warn user about system running low on memory.

Yep, that's true.

But, MemAvailable is calculated from some very cheap counters.  The
"dropcache-based-calculation" requires iterating over every 4k page
cache page in the system.

Do you have some ideas for doing cheap(er) MemAvailable calculations?

We track dirty and writebackw with counters, so we should theoretically
be able to pull those out of MemAvailable fairly cheaply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

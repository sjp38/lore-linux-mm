Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE8B6B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 12:46:28 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 132so39874150lfz.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 09:46:28 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id x80si458400wme.118.2016.06.03.09.46.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jun 2016 09:46:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id DB20E99578
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 16:46:26 +0000 (UTC)
Date: Fri, 3 Jun 2016 17:46:25 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0
Message-ID: <20160603164625.GB2527@techsingularity.net>
References: <20160601091921.GT2527@techsingularity.net>
 <574EB274.4030408@suse.cz>
 <20160602103936.GU2527@techsingularity.net>
 <0eb1f112-65d4-f2e5-911e-697b21324b9f@suse.cz>
 <20160602121936.GV2527@techsingularity.net>
 <20160602114341.e3b974640fc3f8cbcb54898b@linux-foundation.org>
 <CAMuHMdX07bUE+3QTbFmbxrjkXPBzFLoLQbupL=WAbLXTuN+6Ww@mail.gmail.com>
 <20160603084142.GY2527@techsingularity.net>
 <CAMuHMdWPsx0r4HMYy+prhnQaW0bkrm+FHOyzb8vBO7S70FQOog@mail.gmail.com>
 <20160603093518.09699af30ba0555847511487@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160603093518.09699af30ba0555847511487@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Vlastimil Babka <vbabka@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@vger.kernel.org>

On Fri, Jun 03, 2016 at 09:35:18AM -0700, Andrew Morton wrote:
> On Fri, 3 Jun 2016 11:00:30 +0200 Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> 
> > In the mean time my tests completed successfully with both patches applied.
> 
> Can we please identify "both patches" with specificity?  I have the
> below one.
> 

mm, page_alloc: Reset zonelist iterator after resetting fair zone allocation policy
mm, page_alloc: Recalculate the preferred zoneref if the context can ignore memory policies

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

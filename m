Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F10766B02C3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:31:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u17so159934843pfa.6
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:31:16 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id m3si5663779pgc.963.2017.07.25.08.31.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 08:31:16 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id y129so71542500pgy.4
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:31:15 -0700 (PDT)
Date: Tue, 25 Jul 2017 18:31:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725153110.qzfz7wpnxkjwh5bc@node.shutemov.name>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725142626.GJ26723@dhcp22.suse.cz>
 <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
 <20170725152300.GM26723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725152300.GM26723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 25, 2017 at 05:23:00PM +0200, Michal Hocko wrote:
> what is stdev?

Updated tables:

3 runs before the patch:
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.  Stdev
 177200  205000  212900  217800  223700 2377000  32868
 172400  201700  209700  214300  220600 1343000  31191
 175700  203800  212300  217100  223000 1061000  31195

3 runs after the patch:
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.  Stdev
 175900  204800  213000  216400  223600 1989000  27210
 180300  210900  219600  223600  230200 3184000  32609
 182100  212500  222000  226200  232700 1473000  32138

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F40156B03AD
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 12:39:35 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v52so3985855wrb.14
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 09:39:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d63si35072467wmf.112.2017.04.07.09.39.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Apr 2017 09:39:34 -0700 (PDT)
Date: Fri, 7 Apr 2017 18:39:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Is it safe for kthreadd to drain_all_pages?
Message-ID: <20170407163932.GJ16413@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils>
 <20170406130614.a6ygueggpwseqysd@techsingularity.net>
 <alpine.LSU.2.11.1704061134240.17094@eggly.anvils>
 <alpine.LSU.2.11.1704070914520.1566@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1704070914520.1566@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 07-04-17 09:25:33, Hugh Dickins wrote:
[...]
> 24 hours so far, and with a clean /var/log/messages.  Not conclusive
> yet, and of course I'll leave it running another couple of days, but
> I'm increasingly sure that it works as you intended: I agree that
> 
> mm-move-pcp-and-lru-pcp-drainging-into-single-wq.patch
> mm-move-pcp-and-lru-pcp-drainging-into-single-wq-fix.patch
> 
> should go to Linus as soon as convenient.  Though I think the commit
> message needs something a bit stronger than "Quite annoying though".
> Maybe add a line:
> 
> Fixes serious hang under load, observed repeatedly on 4.11-rc.

Yeah, it is much less theoretical now. I will rephrase and ask Andrew to
update the chagelog and send it to Linus once I've got your final go.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

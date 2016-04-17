Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 013986B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 14:53:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so52734577wmw.2
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 11:53:32 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id f193si22974337wmf.21.2016.04.17.11.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 11:53:31 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id v188so92217103wme.1
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 11:53:31 -0700 (PDT)
Date: Sun, 17 Apr 2016 14:53:28 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 107771] New: Single process tries to use more than 1/2
 physical RAM, OS starts thrashing
Message-ID: <20160417185327.GC9051@dhcp22.suse.cz>
References: <bug-107771-27@https.bugzilla.kernel.org/>
 <20160415121549.47e404e3263c71564929884e@linux-foundation.org>
 <1460748682.25336.41.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1460748682.25336.41.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: theosib@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>

On Fri 15-04-16 15:31:22, Rik van Riel wrote:
> On Fri, 2016-04-15 at 12:15 -0700, Andrew Morton wrote:
> > (switched to email.  Please respond via emailed reply-to-all, not via
> > the
> > bugzilla web interface).
> > 
> > This is ... interesting.
> 
> First things first. What is the value of
> /proc/sys/vm/zone_reclaim?

Also snapshots of /proc/vmstat taken every 1s or so while you see the
trashing would be helpful.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

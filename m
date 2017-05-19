Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1BC2831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 03:46:49 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 10so13449865wml.4
        for <linux-mm@kvack.org>; Fri, 19 May 2017 00:46:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j31si7792537edb.213.2017.05.19.00.46.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 00:46:48 -0700 (PDT)
Date: Fri, 19 May 2017 09:46:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] dm ioctl: Restore __GFP_HIGH in copy_params()
Message-ID: <20170519074647.GC13041@dhcp22.suse.cz>
References: <20170518185040.108293-1-junaids@google.com>
 <20170518190406.GB2330@dhcp22.suse.cz>
 <alpine.DEB.2.10.1705181338090.132717@chino.kir.corp.google.com>
 <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junaid Shahid <junaids@google.com>
Cc: David Rientjes <rientjes@google.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, mpatocka@redhat.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

On Thu 18-05-17 19:50:46, Junaid Shahid wrote:
> (Adding back the correct linux-mm email address and also adding linux-kernel.)
> 
> On Thursday, May 18, 2017 01:41:33 PM David Rientjes wrote:
[...]
> > Let's ask Mikulas, who changed this from PF_MEMALLOC to __GFP_HIGH, 
> > assuming there was a reason to do it in the first place in two different 
> > ways.

Hmm, the old PF_MEMALLOC used to have the following comment
        /*
         * Trying to avoid low memory issues when a device is
         * suspended. 
         */

I am not really sure what that means but __GFP_HIGH certainly have a
different semantic than PF_MEMALLOC. The later grants the full access to
the memory reserves while the prior on partial access. If this is _really_
needed then it deserves a comment explaining why.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

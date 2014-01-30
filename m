Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5607D6B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 19:35:41 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id um1so2436817pbc.19
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 16:35:40 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id if4si4375862pbc.16.2014.01.29.16.35.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 16:35:40 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so2434899pad.8
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 16:35:39 -0800 (PST)
Date: Wed, 29 Jan 2014 16:35:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: base root bonus on current usage
In-Reply-To: <20140129122813.59d32e5c5dad3efc2248bc60@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1401291628340.22974@chino.kir.corp.google.com>
References: <20140115234308.GB4407@cmpxchg.org> <alpine.DEB.2.02.1401151614480.15665@chino.kir.corp.google.com> <20140116070709.GM6963@cmpxchg.org> <alpine.DEB.2.02.1401212050340.8512@chino.kir.corp.google.com> <20140124040531.GF4407@cmpxchg.org>
 <alpine.DEB.2.02.1401251942510.3140@chino.kir.corp.google.com> <20140129122813.59d32e5c5dad3efc2248bc60@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 29 Jan 2014, Andrew Morton wrote:

> This changelog has deteriorated :( We should provide sufficient info so
> that people will be able to determine whether this patch will fix a
> problem they or their customers are observing.  And so that people who
> maintain -stable and its derivatives can decide whether to backport it.
> 
> I went back and stole some text from the v1 patch.  Please review the
> result.  The changelog would be even better if it were to describe the
> new behaviour under the problematic workloads.
> 

The new changelog looks fine with the exception of the mention of sshd 
which typically sets itself to be disabled from oom killing altogether.

> We don't think -stable needs this?
> 

Nobody has reported it in over three years as causing an issue, probably 
because people typically have enough memory that oom kills don't come from 
a ton of small processes allocating memory that can't be reclaimed, 
there's usually at least one large process to kill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

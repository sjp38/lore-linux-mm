Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id A165A6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 17:49:29 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id c41so1163697yho.6
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 14:49:29 -0800 (PST)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id j24si12197649yhb.21.2014.01.16.14.49.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 14:49:28 -0800 (PST)
Received: by mail-yk0-f169.google.com with SMTP id q9so1588960ykb.0
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 14:49:28 -0800 (PST)
Date: Thu, 16 Jan 2014 14:49:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 -mm] mm, oom: prefer thread group leaders for display
 purposes
In-Reply-To: <20140116142141.GF28157@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1401161447510.31228@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1401151837560.1835@chino.kir.corp.google.com> <20140116070549.GL6963@cmpxchg.org> <alpine.DEB.2.02.1401152344560.14407@chino.kir.corp.google.com> <alpine.DEB.2.02.1401152345330.14407@chino.kir.corp.google.com>
 <20140116142141.GF28157@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 16 Jan 2014, Michal Hocko wrote:

> > When two threads have the same badness score, it's preferable to kill the 
> > thread group leader so that the actual process name is printed to the 
> > kernel log rather than the thread group name which may be shared amongst 
> > several processes.
> 
> I am not sure I understand this. Is this about ->comm? If yes then why
> couldn't the group leader do PR_SET_NAME?
> 

Both comm and pid, we only display thread group leaders in the tasklist 
dump of eligible processes, we want the killed message to specify from 
which process.

You're suggesting a thread group leader do PR_SET_NAME of all its threads 
for readable oom killer output?  Lol.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

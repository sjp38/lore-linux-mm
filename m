Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBF86B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 18:07:43 -0500 (EST)
Received: by mail-vc0-f181.google.com with SMTP id ks9so8863894vcb.40
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 15:07:43 -0800 (PST)
Received: from mail-yh0-x234.google.com (mail-yh0-x234.google.com [2607:f8b0:4002:c01::234])
        by mx.google.com with ESMTPS id dq5si16683871vcb.24.2013.12.02.15.07.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 15:07:42 -0800 (PST)
Received: by mail-yh0-f52.google.com with SMTP id i72so9297266yha.25
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 15:07:42 -0800 (PST)
Date: Mon, 2 Dec 2013 15:07:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: user defined OOM policies
In-Reply-To: <20131128115458.GK2761@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 28 Nov 2013, Michal Hocko wrote:

> > Agreed, and I think the big downside of doing it with the loadable module 
> > suggestion is that you can't implement such a wide variety of different 
> > policies in modules.  Each of our users who own a memcg tree on our 
> > systems may want to have their own policy and they can't load a module at 
> > runtime or ship with the kernel.
> 
> But those users care about their local (memcg) OOM, don't they? So they
> do not need any module and all they want is to get a notification.

Sure, but I think the question is more of the benefit of doing it in the 
kernel as opposed to userspace.  If we implement the necessary mechanisms 
that allow userspace to reliably handle these situations, I don't see much 
of a benefit to modules other than for separating code amongst multiple 
files in the source.  I don't think we want to ship multiple different oom 
policies because then userspace that cares about it has to figure out 
what's in effect and what it can do with what's available.  I'd argue that 
a the key functionality that I've already described (system oom 
notification, memcg reserves, timeout) allow for any policy to be defined 
reliably in userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

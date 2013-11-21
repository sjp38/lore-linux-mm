Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id EA8F76B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 22:39:03 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so3633048pdj.23
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 19:39:03 -0800 (PST)
Received: from psmtp.com ([74.125.245.171])
        by mx.google.com with SMTP id fb6si4982461pab.327.2013.11.20.19.39.00
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 19:39:01 -0800 (PST)
Received: by mail-yh0-f42.google.com with SMTP id z6so1046004yhz.1
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 19:38:59 -0800 (PST)
Date: Wed, 20 Nov 2013 19:38:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: user defined OOM policies
In-Reply-To: <20131120173357.GC18809@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1311201937120.7167@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <20131120172119.GA1848@hp530> <20131120173357.GC18809@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Murzin <murzin.v@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, 20 Nov 2013, Michal Hocko wrote:

> OK, I was a bit vague it seems. I meant to give zonelist, gfp_mask,
> allocation order and nodemask parameters to the modules. So they have a
> better picture of what is the OOM context.
> What everything ould modules need to do an effective work is a matter
> for discussion.
> 

It's an interesting idea but unfortunately a non-starter for us because 
our users don't have root, we create their memcg tree and then chown it to 
the user.  They can freely register for oom notifications but cannot load 
their own kernel modules for their own specific policy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

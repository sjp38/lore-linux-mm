Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id F30366B0071
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 01:13:15 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2008138pbb.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 22:13:15 -0700 (PDT)
Date: Wed, 20 Jun 2012 22:13:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/buddy: get the allownodes for dump at once
In-Reply-To: <20120621044725.GA20379@shangw>
Message-ID: <alpine.DEB.2.00.1206202212290.25567@chino.kir.corp.google.com>
References: <1339662910-25774-1-git-send-email-shangw@linux.vnet.ibm.com> <alpine.DEB.2.00.1206201815100.3702@chino.kir.corp.google.com> <20120621044725.GA20379@shangw>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, minchan@kernel.org, mgorman@suse.de, akpm@linux-foundation.org

On Thu, 21 Jun 2012, Gavin Shan wrote:

> I'm not sure it's the possible to resolve the concerns with "static" here
> since "allownodes" will be cleared for each call to show_free_areas().
> 
> 	static nodemask_t allownodes;
> 

There's nothing protecting concurrent access to it.  This function 
certainly isn't in a performance sensitive path so I would be inclined to 
just leave it as is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

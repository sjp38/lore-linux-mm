Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 8B85B6B0002
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 17:16:10 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id xa12so636860pbc.8
        for <linux-mm@kvack.org>; Wed, 27 Feb 2013 14:16:09 -0800 (PST)
Date: Wed, 27 Feb 2013 14:16:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, show_mem: suppress page counts in non-blockable
 contexts
In-Reply-To: <20130227100024.GA16724@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1302271413460.7155@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1302261642520.11109@chino.kir.corp.google.com> <20130227100024.GA16724@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 27 Feb 2013, Michal Hocko wrote:

> But we are trying to prevent from soft lockups by calling
> touch_nmi_watchdog every now when iterating over pages so the lock up
> detector shouldn't trigger.
> 
> Anyway, I think that the additional information (which can be really
> costly as you are describing) is not that useful. Most of the useful
> information is already printed by show_free_areas. Or does it help when
> we know how much memory is shared/reserved/etc. when the allocation
> fails?
> 

I do not think it is helpful since show_free_areas() already shows all 
pertinent information, and hence I'm suppressing it in atomic contexts in 
this patch.

> So I do agree with the dropping the additional information for the
> allocation failure path (sysrq+m might still show it) but I fail to see
> how the lockup detector plays any role here. Can we just drop it because
> it is not that interesting and it is costly so it is not worth
> bothering?
>  

I would agree it is not interesting to debugging VM issues and is 
obviously very expensive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

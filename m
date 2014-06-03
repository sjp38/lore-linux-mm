Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC5E6B00A6
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 20:03:07 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id up15so4741398pbc.16
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 17:03:07 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id fo3si17922804pad.223.2014.06.02.17.03.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 17:03:06 -0700 (PDT)
Received: by mail-pd0-f181.google.com with SMTP id z10so3933203pdj.12
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 17:03:05 -0700 (PDT)
Date: Mon, 2 Jun 2014 17:01:44 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mm, memcg: periodically schedule when emptying page
 list
In-Reply-To: <alpine.DEB.2.02.1406021648260.8495@chino.kir.corp.google.com>
Message-ID: <alpine.LSU.2.11.1406021658050.5784@eggly.anvils>
References: <alpine.DEB.2.02.1406021612550.6487@chino.kir.corp.google.com> <alpine.LSU.2.11.1406021637170.5627@eggly.anvils> <alpine.DEB.2.02.1406021648260.8495@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 2 Jun 2014, David Rientjes wrote:
> On Mon, 2 Jun 2014, Hugh Dickins wrote:
> 
> > Why not just move that cond_resched() down below the if/else?
> > No need to test need_resched() separately, and this page is not busy.
> > 
> 
> Would you like to propose your version from our kernel instead?

If that's how you prefer to work it, sure.  The patch would indeed
look uncannily like what I put in our kernel a week ago; but I think
the description might owe a lot to you!  I'll get to it later, while
secretly hoping you get to it sooner :)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

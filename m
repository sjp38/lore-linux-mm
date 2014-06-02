Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0ADE66B00A0
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 19:48:49 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id hn18so4044114igb.0
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 16:48:48 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id rv8si23863225igb.32.2014.06.02.16.48.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 16:48:48 -0700 (PDT)
Received: by mail-ie0-f173.google.com with SMTP id lx4so5244913iec.32
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 16:48:48 -0700 (PDT)
Date: Mon, 2 Jun 2014 16:48:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: periodically schedule when emptying page
 list
In-Reply-To: <alpine.LSU.2.11.1406021637170.5627@eggly.anvils>
Message-ID: <alpine.DEB.2.02.1406021648260.8495@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1406021612550.6487@chino.kir.corp.google.com> <alpine.LSU.2.11.1406021637170.5627@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 2 Jun 2014, Hugh Dickins wrote:

> Why not just move that cond_resched() down below the if/else?
> No need to test need_resched() separately, and this page is not busy.
> 

Would you like to propose your version from our kernel instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

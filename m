Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id DC5766B00B4
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 20:27:34 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md4so8235334pbc.2
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 17:27:34 -0800 (PST)
Received: from psmtp.com ([74.125.245.152])
        by mx.google.com with SMTP id yh6si15590364pab.237.2013.11.05.17.27.32
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 17:27:33 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id rq13so4186933pbb.34
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 17:27:31 -0800 (PST)
Date: Tue, 5 Nov 2013 17:27:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, oom: Fix race when selecting process to kill
In-Reply-To: <CAA25o9SFZW7JxDQGv+h43EMSS3xH0eXy=LoHO_Psmk_n3dxqoA@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1311051727090.29471@chino.kir.corp.google.com>
References: <1383693987-14171-1-git-send-email-snanda@chromium.org> <alpine.DEB.2.02.1311051715090.29471@chino.kir.corp.google.com> <CAA25o9SFZW7JxDQGv+h43EMSS3xH0eXy=LoHO_Psmk_n3dxqoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Sameer Nanda <snanda@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, Johannes Weiner <hannes@cmpxchg.org>, rusty@rustcorp.com.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 5 Nov 2013, Luigi Semenzato wrote:

> It's not enough to hold a reference to the task struct, because it can
> still be taken out of the circular list of threads.  The RCU
> assumptions don't hold in that case.
> 

Could you please post a proper bug report that isolates this at the cause?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

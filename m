Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E21016B00B6
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 22:00:45 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so9990236pab.28
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 19:00:45 -0800 (PST)
Received: from psmtp.com ([74.125.245.194])
        by mx.google.com with SMTP id y7si15504645pbi.203.2013.11.05.19.00.43
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 19:00:44 -0800 (PST)
Received: by mail-lb0-f180.google.com with SMTP id y6so7073224lbh.25
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 19:00:41 -0800 (PST)
Date: Wed, 6 Nov 2013 04:00:04 +0100
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH] mm, oom: Fix race when selecting process to kill
Message-ID: <20131106030000.GA1934@hp530>
References: <1383693987-14171-1-git-send-email-snanda@chromium.org>
 <alpine.DEB.2.02.1311051715090.29471@chino.kir.corp.google.com>
 <CAA25o9SFZW7JxDQGv+h43EMSS3xH0eXy=LoHO_Psmk_n3dxqoA@mail.gmail.com>
 <alpine.DEB.2.02.1311051727090.29471@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311051727090.29471@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luigi Semenzato <semenzato@google.com>, Sameer Nanda <snanda@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, Johannes Weiner <hannes@cmpxchg.org>, rusty@rustcorp.com.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, oleg@redhat.com, dserrg@gmail.com

Ccing Oleg and Sergey

On Tue, Nov 05, 2013 at 05:27:29PM -0800, David Rientjes wrote:
> On Tue, 5 Nov 2013, Luigi Semenzato wrote:
> 
> > It's not enough to hold a reference to the task struct, because it can
> > still be taken out of the circular list of threads.  The RCU
> > assumptions don't hold in that case.
> > 
> 
> Could you please post a proper bug report that isolates this at the cause?
>
Hi David!

I think it has already been reported[1] and actively discussed. Oleg has
confirmed that while_each_thread() is not safe under rcu_read_lock()[2].

Oleg, any news about your activity for fixing that?

[1] http://www.spinics.net/lists/linux-mm/msg54836.html
[2] http://marc.info/?l=linux-kernel&m=127688978121665
> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

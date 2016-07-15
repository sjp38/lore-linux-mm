Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD856B026D
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 17:40:00 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c52so226896408qte.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:40:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n125si6709119qkd.210.2016.07.15.14.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 14:39:59 -0700 (PDT)
Date: Fri, 15 Jul 2016 17:39:55 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <alpine.DEB.2.10.1607151422140.121215@chino.kir.corp.google.com>
Message-ID: <alpine.LRH.2.02.1607151730430.21114@file01.intranet.prod.int.rdu2.redhat.com>
References: <57837CEE.1010609@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com> <20160712064905.GA14586@dhcp22.suse.cz> <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp> <20160713133955.GK28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com> <20160713145638.GM28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com> <alpine.LRH.2.02.1607140818250.15554@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607141316240.68666@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1607150711270.5034@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607151422140.121215@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com



On Fri, 15 Jul 2016, David Rientjes wrote:

> On Fri, 15 Jul 2016, Mikulas Patocka wrote:
> 
> > > There is no guarantee that _anything_ can return memory to the mempool,
> > 
> > You misunderstand mempools if you make such claims.
> > 
> > There is in fact guarantee that objects will be returned to mempool. In 
> > the past I reviewed device mapper thoroughly to make sure that it can make 
> > forward progress even if there is no available memory.
> > 
> > I don't know what should I tell you if you keep on repeating the same 
> > false claim over and over again. Should I explain mempool oprerations to 
> > you in detail? Or will you find it on your own?
> > 
> 
> If you are talking about patches you're proposing for 4.8 or any guarantee 
> of memory freeing that the oom killer/reaper will provide in 4.8, that's 
> fine.  However, the state of the 4.7 kernel is the same as it was when I 
> fixed this issue that timed out hundreds of our machines and is 
> contradicted by that evidence.  Our machines time out after two hours with 
> the oom victim looping forever in mempool_alloc(), so if there was a 

And what about the oom reaper? It should have freed all victim's pages 
even if the victim is looping in mempool_alloc. Why the oom reaper didn't 
free up memory?

> guarantee that elements would be returned in a completely livelocked 
> kernel in 4.7 or earlier kernels, that would not have been the case.  I 

And what kind of targets do you use in device mapper in the configuration 
that livelocked? Do you use some custom google-developed drivers?

Please describe the whole stack of block I/O devices when this livelock 
happened.

Most device mapper drivers can really make forward progress when they are 
out of memory, so I'm interested what kind of configuration do you have.

> frankly don't care about your patch reviewing of dm mempool usage when 
> dm_request() livelocked our kernel.

If it livelocked, it is a bug in some underlying block driver, not a bug 
in mempool_alloc.

> Feel free to formally propose patches either for 4.7 or 4.8.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

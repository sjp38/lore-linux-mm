Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAAAC6B025F
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 07:22:03 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id i12so187177629ywa.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 04:22:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r12si4940997qtr.135.2016.07.15.04.22.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 04:22:03 -0700 (PDT)
Date: Fri, 15 Jul 2016 07:21:59 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <alpine.DEB.2.10.1607141316240.68666@chino.kir.corp.google.com>
Message-ID: <alpine.LRH.2.02.1607150711270.5034@file01.intranet.prod.int.rdu2.redhat.com>
References: <57837CEE.1010609@redhat.com> <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com> <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp> <20160713133955.GK28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713145638.GM28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com> <alpine.LRH.2.02.1607140818250.15554@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1607141316240.68666@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com



On Thu, 14 Jul 2016, David Rientjes wrote:

> There is no guarantee that _anything_ can return memory to the mempool,

You misunderstand mempools if you make such claims.

There is in fact guarantee that objects will be returned to mempool. In 
the past I reviewed device mapper thoroughly to make sure that it can make 
forward progress even if there is no available memory.

I don't know what should I tell you if you keep on repeating the same 
false claim over and over again. Should I explain mempool oprerations to 
you in detail? Or will you find it on your own?

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

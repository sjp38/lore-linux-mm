Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 3FC636B0092
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 09:49:24 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so66892gge.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 06:49:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFLxGvyVbDndbu_2ZbUBwbrJCq+d4rRZW0ROxTpQxAvetRm=0w@mail.gmail.com>
References: <CAFPAmTQs9dOpQTaXU=6Or66YU+my_CnPw33TE4h++YArBNa38g@mail.gmail.com>
	<CAFLxGvwW2XcYSoidZZ0XF_a-pH3SwONqS+hCnpGUecQ__DLa_g@mail.gmail.com>
	<CAFPAmTSzV9mrkbP68p4PA-0i0o2Hz7JiBY=0A0V_myJEzWubjQ@mail.gmail.com>
	<CAFLxGvyVbDndbu_2ZbUBwbrJCq+d4rRZW0ROxTpQxAvetRm=0w@mail.gmail.com>
Date: Tue, 20 Mar 2012 09:49:22 -0400
Message-ID: <CAFPAmTQxKhmmEaaCEL6bCsKartfOhgmTn5gTLEB+_QzW6O2RjQ@mail.gmail.com>
Subject: Re: [PATCH 0/20] mmu: arch/mm: Port OOM changes to arch page fault handlers.
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

> No problem.
> handle_page_fault() is the function you want to patch. :)
>

Sent.
Terribly sorry for the miss.

Also, the UML page fault handler has some differences from the other
page fault handlers,
so I apologize if I have made some wrong assumptions or mistakes.


> --
> Thanks,
> //richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

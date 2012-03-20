Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 57D816B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 09:36:07 -0400 (EDT)
Received: by yenm8 with SMTP id m8so49101yen.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 06:36:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFPAmTSzV9mrkbP68p4PA-0i0o2Hz7JiBY=0A0V_myJEzWubjQ@mail.gmail.com>
References: <CAFPAmTQs9dOpQTaXU=6Or66YU+my_CnPw33TE4h++YArBNa38g@mail.gmail.com>
	<CAFLxGvwW2XcYSoidZZ0XF_a-pH3SwONqS+hCnpGUecQ__DLa_g@mail.gmail.com>
	<CAFPAmTSzV9mrkbP68p4PA-0i0o2Hz7JiBY=0A0V_myJEzWubjQ@mail.gmail.com>
Date: Tue, 20 Mar 2012 14:36:06 +0100
Message-ID: <CAFLxGvyVbDndbu_2ZbUBwbrJCq+d4rRZW0ROxTpQxAvetRm=0w@mail.gmail.com>
Subject: Re: [PATCH 0/20] mmu: arch/mm: Port OOM changes to arch page fault handlers.
From: richard -rw- weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux@lists.openrisc.net, linux-am33-list@redhat.com, microblaze-uclinux@itee.uq.edu.au, linux-m68k@lists.linux-m68k.org, linux-m32r-ja@ml.linux-m32r.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-cris-kernel@axis.com, linux-sh@vger.kernel.org, linux-parisc@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 20, 2012 at 2:34 PM, Kautuk Consul <consul.kautuk@gmail.com> wrote:
>>
>> What about arch/um/?
>> Does UML not need this change?
>
> Oh yes, extremely sorry I accidentally missed that one out.
> Mind if I send it separately ?

No problem.
handle_page_fault() is the function you want to patch. :)

-- 
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

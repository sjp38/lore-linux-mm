Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3BD6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 06:44:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id m33so1994919wrm.23
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 03:44:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y14si7992134wrd.240.2017.03.29.03.44.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 03:44:00 -0700 (PDT)
Date: Wed, 29 Mar 2017 12:43:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] module: check if memory leak by module.
Message-ID: <20170329104355.GG27994@dhcp22.suse.cz>
References: <alpine.LSU.2.20.1703290958390.4250@pobox.suse.cz>
 <1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
 <20170329074522.GB27994@dhcp22.suse.cz>
 <CGME20170329060315epcas5p1c6f7ce3aca1b2770c5e1d9aaeb1a27e1@epcms5p1>
 <20170329092332epcms5p10ae8263c6e3ef14eac40e08a09eff9e6@epcms5p1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170329092332epcms5p10ae8263c6e3ef14eac40e08a09eff9e6@epcms5p1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaneet Narang <v.narang@samsung.com>
Cc: Miroslav Benes <mbenes@suse.cz>, Maninder Singh <maninder1.s@samsung.com>, "jeyu@redhat.com" <jeyu@redhat.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris@chris-wilson.co.uk" <chris@chris-wilson.co.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "joonas.lahtinen@linux.intel.com" <joonas.lahtinen@linux.intel.com>, "keescook@chromium.org" <keescook@chromium.org>, "pavel@ucw.cz" <pavel@ucw.cz>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "anisse@astier.eu" <anisse@astier.eu>, "rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>, "zijun_hu@htc.com" <zijun_hu@htc.com>, "mingo@kernel.org" <mingo@kernel.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "thgarnie@google.com" <thgarnie@google.com>, "joelaf@google.com" <joelaf@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, PANKAJ MISHRA <pankaj.m@samsung.com>, Ajeet Kumar Yadav <ajeet.y@samsung.com>, =?utf-8?B?7J207ZWZ67SJ?= <hakbong5.lee@samsung.com>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, =?utf-8?B?656E66a/?= <lalit.mohan@samsung.com>, CPGS <cpgs@samsung.com>

On Wed 29-03-17 09:23:32, Vaneet Narang wrote:
> Hi,
> 
> >> Hmm, how can you track _all_ vmalloc allocations done on behalf of the
> >> module? It is quite some time since I've checked kernel/module.c but
> >> from my vague understading your check is basically only about statically
> >> vmalloced areas by module loader. Is that correct? If yes then is this
> >> actually useful? Were there any bugs in the loader code recently? What
> >> led you to prepare this patch? All this should be part of the changelog!
> 
> First of all there is no issue in kernel/module.c. This patch add functionality
> to detect scenario where some kernel module does some memory allocation but gets
> unloaded without doing vfree. For example
> static int kernel_init(void)
> {
>         char * ptr = vmalloc(400 * 1024);
>         return 0;
> }

How can you track that allocation back to the module? Does this patch
actually works at all? Also why would be vmalloc more important than
kmalloc allocations?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

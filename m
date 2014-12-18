Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8D83F6B0072
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 19:40:02 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id rp18so167883iec.39
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:40:02 -0800 (PST)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id a7si12452185iga.52.2014.12.17.16.40.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 16:40:01 -0800 (PST)
Received: by mail-ig0-f171.google.com with SMTP id z20so35353igj.16
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:40:00 -0800 (PST)
Date: Wed, 17 Dec 2014 16:39:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: hugetlb: fix type of hugetlb_treat_as_movable
 variable
In-Reply-To: <1418826650-10145-2-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.10.1412171639430.23841@chino.kir.corp.google.com>
References: <548CA6B6.3060901@colorfullife.com> <1418826650-10145-1-git-send-email-a.ryabinin@samsung.com> <1418826650-10145-2-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: akpm@linux-foundation.org, Dmitry Vyukov <dvyukov@google.com>, Manfred Spraul <manfred@colorfullife.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "nadia.derbey@bull.net" <Nadia.Derbey@bull.net>, aquini@redhat.com, Joe Perches <joe@perches.com>, avagin@openvz.org, LKML <linux-kernel@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <andreyknvl@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>, kasan-dev <kasan-dev@googlegroups.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org

On Wed, 17 Dec 2014, Andrey Ryabinin wrote:

> hugetlb_treat_as_movable declared as unsigned long, but
> proc_dointvec() used for parsing it:
> 
> static struct ctl_table vm_table[] = {
> ...
> 	{
> 		.procname	= "hugepages_treat_as_movable",
> 		.data		= &hugepages_treat_as_movable,
> 		.maxlen		= sizeof(int),
> 		.mode		= 0644,
> 		.proc_handler	= proc_dointvec,
> 	},
> 
> This seems harmless, but it's better to use int type here.
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BCB9A6B0009
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 08:10:41 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m19so2081913pgv.5
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 05:10:41 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 33-v6si4651389plu.508.2018.02.16.05.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 05:10:40 -0800 (PST)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1GDAZC6021313
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:10:39 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2g5xb6gfq3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:10:37 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w1GD9HeJ022801
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:09:18 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w1GD9HTU024054
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:09:17 GMT
Received: by mail-ot0-f181.google.com with SMTP id q12so2626511otg.10
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 05:09:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180216091918.axu57tfsezzybeoa@gmail.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-6-pasha.tatashin@oracle.com> <20180216091918.axu57tfsezzybeoa@gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 16 Feb 2018 08:09:15 -0500
Message-ID: <CAOAebxuwVqjbKuHfpNn9=YBR397pjK-QfF-Akh7UuoEfkW0PWw@mail.gmail.com>
Subject: Re: [v4 5/6] mm/memory_hotplug: don't read nid from struct page
 during hotplug
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

> The namespace of all these memory range handling functions is horribly random,
> and I think now it got worse: we add an assumption that register_new_memory() is
> implicitly called as part of hotplugged memory (where things are pre-cleared) -
> but nothing in its naming suggests so.
>
> How about renaming it to hotplug_memory_register() or so?

Sure, I will rename it.

>
> With that change you can add:
>
>   Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

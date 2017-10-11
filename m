Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5DBBA6B0268
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 10:16:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r68so3009240wmr.6
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 07:16:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m28si10586245wmc.149.2017.10.11.07.16.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 07:16:19 -0700 (PDT)
Date: Wed, 11 Oct 2017 16:16:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
Message-ID: <20171011141616.7mo6g7qnd3df7ab5@dhcp22.suse.cz>
References: <20170918070834.13083-1-mhocko@kernel.org>
 <20170918070834.13083-2-mhocko@kernel.org>
 <87bmlfw6mj.fsf@concordia.ellerman.id.au>
 <20171010122726.6jrfdzkscwge6gez@dhcp22.suse.cz>
 <87infmz9xd.fsf@concordia.ellerman.id.au>
 <87a80yz2gm.fsf@concordia.ellerman.id.au>
 <fa9bd463-bb94-f060-bd57-2a1416a125df@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa9bd463-bb94-f060-bd57-2a1416a125df@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed 11-10-17 19:35:04, Anshuman Khandual wrote:
[...]
> >   $ grep __init_begin /proc/kallsyms
> >   c000000000d70000 T __init_begin
> >   $ ./page-types -r -a 0x0,0xd7
> >                flags	page-count       MB  symbolic-flags			long-symbolic-flags
> >   0x0000000100000000	       215       13  __________________________r_______________	reserved
> >                total	       215       13
> 
> Hey Michael,
> 
> What tool is this 'page-types' ?

tools/vm/page-types.c

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

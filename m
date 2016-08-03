Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2CC6B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 07:34:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so388198260pfd.3
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 04:34:25 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id n6si8549324pap.89.2016.08.03.04.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 04:34:22 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 2/2] fadump: Disable deferred page struct initialisation
In-Reply-To: <acefe941-2c2a-d7d2-0720-4cfbee404a16@suse.cz>
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com> <1470143947-24443-3-git-send-email-srikar@linux.vnet.ibm.com> <1470201642.5034.3.camel@gmail.com> <acefe941-2c2a-d7d2-0720-4cfbee404a16@suse.cz>
Date: Wed, 03 Aug 2016 21:34:11 +1000
Message-ID: <87twf2ulvw.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux--foundation.org>, linuxppc-dev@lists.ozlabs.org

Vlastimil Babka <vbabka@suse.cz> writes:

> On 08/03/2016 07:20 AM, Balbir Singh wrote:
>> On Tue, 2016-08-02 at 18:49 +0530, Srikar Dronamraju wrote:
>>> Fadump kernel reserves significant number of memory blocks. On a multi-node
>>> machine, with CONFIG_DEFFERRED_STRUCT_PAGE support, fadump kernel fails to
>>> boot. Fix this by disabling deferred page struct initialisation.
>>>
>>
>> How much memory does a fadump kernel need? Can we bump up the limits depending
>> on the config. I presume when you say fadump kernel you mean kernel with
>> FADUMP in the config?
>>
>> BTW, I would much rather prefer a config based solution that does not select
>> DEFERRED_INIT if FADUMP is enabled.
>
> IIRC the kdump/fadump kernel is typically the same vmlinux as the main 
> kernel, just with special initrd and boot params. So if you want 
> deferred init for the main kernel, this would be impractical.

Yes. Distros won't build a separate kernel, so it has to work at runtime.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

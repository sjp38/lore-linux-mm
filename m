Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 190E16B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 02:07:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so117629725wml.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 23:07:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nh2si6471557wjb.15.2016.08.02.23.07.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 23:07:21 -0700 (PDT)
Subject: Re: [PATCH 2/2] fadump: Disable deferred page struct initialisation
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1470143947-24443-3-git-send-email-srikar@linux.vnet.ibm.com>
 <1470201642.5034.3.camel@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <acefe941-2c2a-d7d2-0720-4cfbee404a16@suse.cz>
Date: Wed, 3 Aug 2016 08:07:19 +0200
MIME-Version: 1.0
In-Reply-To: <1470201642.5034.3.camel@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux--foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org

On 08/03/2016 07:20 AM, Balbir Singh wrote:
> On Tue, 2016-08-02 at 18:49 +0530, Srikar Dronamraju wrote:
>> Fadump kernel reserves significant number of memory blocks. On a multi-node
>> machine, with CONFIG_DEFFERRED_STRUCT_PAGE support, fadump kernel fails to
>> boot. Fix this by disabling deferred page struct initialisation.
>>
>
> How much memory does a fadump kernel need? Can we bump up the limits depending
> on the config. I presume when you say fadump kernel you mean kernel with
> FADUMP in the config?
>
> BTW, I would much rather prefer a config based solution that does not select
> DEFERRED_INIT if FADUMP is enabled.

IIRC the kdump/fadump kernel is typically the same vmlinux as the main 
kernel, just with special initrd and boot params. So if you want 
deferred init for the main kernel, this would be impractical.

> Balbir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

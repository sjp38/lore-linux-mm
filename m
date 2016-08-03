Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C76A86B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 01:20:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so377224234pfx.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 22:20:35 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id l78si6929281pfj.253.2016.08.02.22.20.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 22:20:35 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id cf3so13262913pad.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 22:20:35 -0700 (PDT)
Message-ID: <1470201642.5034.3.camel@gmail.com>
Subject: Re: [PATCH 2/2] fadump: Disable deferred page struct initialisation
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 03 Aug 2016 15:20:42 +1000
In-Reply-To: <1470143947-24443-3-git-send-email-srikar@linux.vnet.ibm.com>
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
	 <1470143947-24443-3-git-send-email-srikar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux--foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org

On Tue, 2016-08-02 at 18:49 +0530, Srikar Dronamraju wrote:
> Fadump kernel reserves significant number of memory blocks. On a multi-node
> machine, with CONFIG_DEFFERRED_STRUCT_PAGE support, fadump kernel fails to
> boot. Fix this by disabling deferred page struct initialisation.
>A 

How much memory does a fadump kernel need? Can we bump up the limits depending
on the config. I presume when you say fadump kernel you mean kernel with
FADUMP in the config?

BTW, I would much rather prefer a config based solution that does not select
DEFERRED_INIT if FADUMP is enabled.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB0BF6B205B
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 15:40:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v1-v6so3096202wmh.4
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 12:40:48 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id w15-v6si2686761wmf.191.2018.08.21.12.40.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 12:40:46 -0700 (PDT)
Date: Tue, 21 Aug 2018 12:40:43 -0700 (PDT)
Message-Id: <20180821.124043.1345592906200206631.davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] sparc32: switch to NO_BOOTMEM
From: David Miller <davem@davemloft.net>
In-Reply-To: <1533552755-16679-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1533552755-16679-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: sam@ravnborg.org, mhocko@kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Mon,  6 Aug 2018 13:52:32 +0300

> These patches convert sparc32 to use memblock + nobootmem.
> I've made the conversion as simple as possible, just enough to allow moving
> HAVE_MEMBLOCK and NO_BOOTMEM to the common SPARC configuration.
> 
> v2 changes:
> * split whitespace changes to a separate patch
> * address Sam's comments [1]
> 
> [1] https://lkml.org/lkml/2018/8/2/403

Series applied, thank you.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8221F44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 19:03:32 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h28so3562831pfh.16
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 16:03:32 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f7si4857903pgn.699.2017.11.08.16.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 16:03:25 -0800 (PST)
Date: Wed, 8 Nov 2017 16:03:24 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [lkp-robot] [mm]  47bd678bc7:
 WARNING:at_mm/workingset.c:#scan_shadow_nodes
Message-ID: <20171109000324.GD8522@tassilo.jf.intel.com>
References: <20171026234854.25764-1-andi@firstfloor.org>
 <20171108015629.GA22793@yexl-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108015629.GA22793@yexl-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <xiaolong.ye@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, lkp@01.org

> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
> 
> 
> kern  :warn  : [  348.637225] WARNING: CPU: 3 PID: 53 at mm/workingset.c:456 scan_shadow_nodes+0x240/0x260

Thanks.

It's likely the truncate problem found by Hannes during review.

Next revision should fix it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

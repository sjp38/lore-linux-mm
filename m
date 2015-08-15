Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 19E886B0038
	for <linux-mm@kvack.org>; Sat, 15 Aug 2015 03:27:01 -0400 (EDT)
Received: by lbbtg9 with SMTP id tg9so57092692lbb.1
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 00:27:00 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id sc4si7527743lbb.99.2015.08.15.00.26.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Aug 2015 00:26:59 -0700 (PDT)
Received: by lahi9 with SMTP id i9so54505295lah.2
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 00:26:58 -0700 (PDT)
Date: Sat, 15 Aug 2015 13:26:36 +0600
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: Re: [PATCH] mm/memblock: validate the creation of debugfs files
Message-ID: <20150815072636.GA2539@localhost>
References: <1439579011-14918-1-git-send-email-kuleshovmail@gmail.com>
 <20150814141944.4172fee6c9d7ae02a6258c80@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150814141944.4172fee6c9d7ae02a6258c80@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Baoquan He <bhe@redhat.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Andrew,

On 08-14-15, Andrew Morton wrote:
> On Sat, 15 Aug 2015 01:03:31 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:
> 
> > Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
> 
> There's no changelog.

Yes, will add it if there will be sense in the patch.

> 
> Why?  Ignoring the debugfs API return values is standard practice.
> 

Yes, but I saw many places where this practice is applicable (for example
in the kernel/kprobes and etc.), besides this, the memblock API is used
mostly at early stage, so we will have some output if something going wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

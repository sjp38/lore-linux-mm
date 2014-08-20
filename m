Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0B67D6B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 16:13:54 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so12653433pdj.28
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 13:13:54 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id jf9si33200753pbd.242.2014.08.20.13.13.44
        for <linux-mm@kvack.org>;
        Wed, 20 Aug 2014 13:13:44 -0700 (PDT)
Message-ID: <1408565596.26863.13.camel@rzwisler-mobl1.amr.corp.intel.com>
Subject: Re: [RFC 0/9] pmem: Support for "struct page" with Persistent
 Memory storage
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Date: Wed, 20 Aug 2014 14:13:16 -0600
In-Reply-To: <53EB5536.8020702@gmail.com>
References: <53EB5536.8020702@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On Wed, 2014-08-13 at 15:08 +0300, Boaz Harrosh wrote:
> And one last Rant if I may?
> I hate the prd name, why why? OK so a freak of bad luck forced us to invent a new name for
> /dev/ram because it would be weird to do an lsmod and see a ram.ko hanging there which is actually
> a block device driver. OK so a brd == /dev/ram. But why do we need to carry this punishment forever?
> Why an additional/different name in the namespace? /dev/foo should just be foo.ko in lsmod, No?
> So please, please, for my peace of mind can we call this driver pmem.ko?
> I know, I would hate it if I was inventing a name and people change it, so Ross it is your call, is
> it OK if we move back to just call it pmem everywhere?

Hi Boaz,

Yep, I'm fine with the rename from prd to pmem everywhere.  I've made this
change and will be pushing out an updated version to my GitHub repo shortly.

Thanks,
- Ross


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

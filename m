Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 06DCA6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 11:33:39 -0400 (EDT)
Received: by igfj19 with SMTP id j19so14457686igf.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:33:38 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id ht3si33569229pdb.231.2015.08.25.08.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Aug 2015 08:33:38 -0700 (PDT)
Message-ID: <55DC8ACE.1080804@windriver.com>
Date: Tue, 25 Aug 2015 11:33:34 -0400
From: Paul Gortmaker <paul.gortmaker@windriver.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] mm: make slab_common.c explicitly non-modular
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com> <1440454482-12250-3-git-send-email-paul.gortmaker@windriver.com> <alpine.DEB.2.11.1508250959200.15945@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1508250959200.15945@east.gentwo.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 2015-08-25 10:59 AM, Christoph Lameter wrote:
> On Mon, 24 Aug 2015, Paul Gortmaker wrote:
> 
>> @@ -1113,7 +1113,7 @@ static int __init slab_proc_init(void)
>>  						&proc_slabinfo_operations);
>>  	return 0;
>>  }
>> -module_init(slab_proc_init);
>> +device_initcall(slab_proc_init);
>>  #endif /* CONFIG_SLABINFO */
>>
>>  static __always_inline void *__do_krealloc(const void *p, size_t new_size,
> 
> True memory management is not a module. But its also not a device.

Per the 0/N I'd rather make it equivalent to what it was already
at this point in time and then consider making it a core_initcall
or post_core early in the next dev cycle if we want to give it
a more appropriately matching category, so we can then watch for
init reordering fallout with more time on our hands.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

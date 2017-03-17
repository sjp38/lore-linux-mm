Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C1BF96B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:02:40 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p5so70945231qtb.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:02:40 -0700 (PDT)
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com. [209.85.220.182])
        by mx.google.com with ESMTPS id 143si1618261qki.268.2017.03.17.11.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 11:02:39 -0700 (PDT)
Received: by mail-qk0-f182.google.com with SMTP id p64so70838949qke.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:02:39 -0700 (PDT)
Subject: Re: [RFC PATCH 08/12] cma: Store a name in the cma structure
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1488491084-17252-9-git-send-email-labbott@redhat.com>
 <CAO_48GEHxuMMwZO71ytaVhRkapMYaAWBWd1gW+ktspnQg=b8Sw@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <7c750fb1-d019-03c1-a682-3bc04c6730ac@redhat.com>
Date: Fri, 17 Mar 2017 11:02:34 -0700
MIME-Version: 1.0
In-Reply-To: <CAO_48GEHxuMMwZO71ytaVhRkapMYaAWBWd1gW+ktspnQg=b8Sw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>
Cc: Riley Andrews <riandrews@android.com>, =?UTF-8?B?QXJ2ZSBIau+/vW5uZXY=?= =?UTF-8?B?77+9Zw==?= <arve@android.com>, Rom Lemarchand <romlem@google.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linaro MM SIG <linaro-mm-sig@lists.linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/10/2017 12:53 AM, Sumit Semwal wrote:
> Hi Laura,
> 
> Thanks for the patch.
> 
> On 3 March 2017 at 03:14, Laura Abbott <labbott@redhat.com> wrote:
>>
>> Frameworks that may want to enumerate CMA heaps (e.g. Ion) will find it
>> useful to have an explicit name attached to each region. Store the name
>> in each CMA structure.
>>
>> Signed-off-by: Laura Abbott <labbott@redhat.com>
>> ---
>>  drivers/base/dma-contiguous.c |  5 +++--
>>  include/linux/cma.h           |  4 +++-
>>  mm/cma.c                      | 11 +++++++++--
>>  mm/cma.h                      |  1 +
>>  mm/cma_debug.c                |  2 +-
>>  5 files changed, 17 insertions(+), 6 deletions(-)
>>
> <snip>
>> +const char *cma_get_name(const struct cma *cma)
>> +{
>> +       return cma->name ? cma->name : "(undefined)";
>> +}
>> +
> Would it make sense to perhaps have the idx stored as the name,
> instead of 'undefined'? That would make sure that the various cma
> names are still unique.
> 

Good suggestion. I'll see about cleaning that up.

>>  static unsigned long cma_bitmap_aligned_mask(const struct cma *cma,
>>                                              int align_order)
>>  {
>> @@ -168,6 +173,7 @@ core_initcall(cma_init_reserved_areas);
>>   */
>>  int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
>>                                  unsigned int order_per_bit,
>> +                                const char *name,
>>                                  struct cma **res_cma)
>>  {
> 
> Best regards,
> Sumit.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

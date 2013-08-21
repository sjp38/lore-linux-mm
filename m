Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 907B96B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 00:28:30 -0400 (EDT)
Received: by mail-oa0-f49.google.com with SMTP id n10so2636744oag.36
        for <linux-mm@kvack.org>; Tue, 20 Aug 2013 21:28:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52142ffe.84c0440a.57e5.02acSMTPIN_ADDED_BROKEN@mx.google.com>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<1376981696-4312-2-git-send-email-liwanp@linux.vnet.ibm.com>
	<20130820160735.b12fe1b3dd64b4dc146d2fa0@linux-foundation.org>
	<CAE9FiQVy2uqLm2XyStYmzxSmsw7TzrB0XDhCRLymnf+L3NPxrA@mail.gmail.com>
	<52142ffe.84c0440a.57e5.02acSMTPIN_ADDED_BROKEN@mx.google.com>
Date: Tue, 20 Aug 2013 21:28:29 -0700
Message-ID: <CAE9FiQW1c3-d+iMebRK6JyHCpMt8mjga-TnsfTuVsC1bQZqsYA@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] mm/sparse: introduce alloc_usemap_and_memmap
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 20, 2013 at 8:11 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> Hi Yinghai,
> On Tue, Aug 20, 2013 at 05:02:17PM -0700, Yinghai Lu wrote:
>>>> -     /* ok, last chunk */
>>>> -     sparse_early_usemaps_alloc_node(usemap_map, pnum_begin, NR_MEM_SECTIONS,
>>>> -                                      usemap_count, nodeid_begin);
>>>> +     alloc_usemap_and_memmap(usemap_map, true);
>>
>>alloc_usemap_and_memmap() is somehow confusing.
>>
>>Please check if you can pass function pointer instead of true/false.
>>
>
> sparse_early_usemaps_alloc_node and sparse_early_mem_maps_alloc_node is
> similar, however, one has a parameter unsigned long ** and the other has
> struct page **. function pointer can't help, isn't it? ;-)

you could have one generic function pointer like
void *alloc_func(void *data);

and in the every alloc function, have own struct data to pass in/out...

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id DC0ED6B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 01:19:53 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id v19so1043100obq.11
        for <linux-mm@kvack.org>; Wed, 21 Aug 2013 22:19:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52146c58.a3e2440a.0f5a.ffffed8dSMTPIN_ADDED_BROKEN@mx.google.com>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<1376981696-4312-2-git-send-email-liwanp@linux.vnet.ibm.com>
	<20130820160735.b12fe1b3dd64b4dc146d2fa0@linux-foundation.org>
	<CAE9FiQVy2uqLm2XyStYmzxSmsw7TzrB0XDhCRLymnf+L3NPxrA@mail.gmail.com>
	<52142ffe.84c0440a.57e5.02acSMTPIN_ADDED_BROKEN@mx.google.com>
	<CAE9FiQW1c3-d+iMebRK6JyHCpMt8mjga-TnsfTuVsC1bQZqsYA@mail.gmail.com>
	<52146c58.a3e2440a.0f5a.ffffed8dSMTPIN_ADDED_BROKEN@mx.google.com>
Date: Wed, 21 Aug 2013 22:19:52 -0700
Message-ID: <CAE9FiQVWVzO93RM_QT-Qp+5jJUEiw=5OOD_454fCjgQ5p9-b3g@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] mm/sparse: introduce alloc_usemap_and_memmap
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Aug 21, 2013 at 12:29 AM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> Hi Yinghai,
> On Tue, Aug 20, 2013 at 09:28:29PM -0700, Yinghai Lu wrote:
>>On Tue, Aug 20, 2013 at 8:11 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>>> Hi Yinghai,
>>> On Tue, Aug 20, 2013 at 05:02:17PM -0700, Yinghai Lu wrote:
>>>>>> -     /* ok, last chunk */
>>>>>> -     sparse_early_usemaps_alloc_node(usemap_map, pnum_begin, NR_MEM_SECTIONS,
>>>>>> -                                      usemap_count, nodeid_begin);
>>>>>> +     alloc_usemap_and_memmap(usemap_map, true);
>>>>
>>>>alloc_usemap_and_memmap() is somehow confusing.
>>>>
>>>>Please check if you can pass function pointer instead of true/false.
>>>>
>>>
>>> sparse_early_usemaps_alloc_node and sparse_early_mem_maps_alloc_node is
>>> similar, however, one has a parameter unsigned long ** and the other has
>>> struct page **. function pointer can't help, isn't it? ;-)
>>
>>you could have one generic function pointer like
>>void *alloc_func(void *data);
>>
>>and in the every alloc function, have own struct data to pass in/out...
>>
>>Yinghai
>
> How about this?

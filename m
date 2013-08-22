Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 871766B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 08:15:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 22 Aug 2013 22:04:34 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 761A3357804E
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 22:14:56 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7MCEiSg60620894
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 22:14:45 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7MCEs3a022020
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 22:14:55 +1000
Date: Thu, 22 Aug 2013 20:14:52 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/4] mm/sparse: introduce alloc_usemap_and_memmap
Message-ID: <20130822121452.GA12587@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1376981696-4312-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130820160735.b12fe1b3dd64b4dc146d2fa0@linux-foundation.org>
 <CAE9FiQVy2uqLm2XyStYmzxSmsw7TzrB0XDhCRLymnf+L3NPxrA@mail.gmail.com>
 <52142ffe.84c0440a.57e5.02acSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQW1c3-d+iMebRK6JyHCpMt8mjga-TnsfTuVsC1bQZqsYA@mail.gmail.com>
 <52146c58.a3e2440a.0f5a.ffffed8dSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQVWVzO93RM_QT-Qp+5jJUEiw=5OOD_454fCjgQ5p9-b3g@mail.gmail.com>
 <20130822120809.GA6489@hacker.(null)>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Content-Disposition: inline
In-Reply-To: <20130822120809.GA6489@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Aug 22, 2013 at 08:08:09PM +0800, Wanpeng Li wrote:
>On Wed, Aug 21, 2013 at 10:19:52PM -0700, Yinghai Lu wrote:
>>On Wed, Aug 21, 2013 at 12:29 AM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>>> Hi Yinghai,
>>> On Tue, Aug 20, 2013 at 09:28:29PM -0700, Yinghai Lu wrote:
>>>>On Tue, Aug 20, 2013 at 8:11 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>>>>> Hi Yinghai,
>>>>> On Tue, Aug 20, 2013 at 05:02:17PM -0700, Yinghai Lu wrote:
>>>>>>>> -     /* ok, last chunk */
>>>>>>>> -     sparse_early_usemaps_alloc_node(usemap_map, pnum_begin, NR_MEM_SECTIONS,
>>>>>>>> -                                      usemap_count, nodeid_begin);
>>>>>>>> +     alloc_usemap_and_memmap(usemap_map, true);
>>>>>>
>>>>>>alloc_usemap_and_memmap() is somehow confusing.
>>>>>>
>>>>>>Please check if you can pass function pointer instead of true/false.
>>>>>>
>>>>>
>>>>> sparse_early_usemaps_alloc_node and sparse_early_mem_maps_alloc_node is
>>>>> similar, however, one has a parameter unsigned long ** and the other has
>>>>> struct page **. function pointer can't help, isn't it? ;-)
>>>>
>>>>you could have one generic function pointer like
>>>>void *alloc_func(void *data);
>>>>
>>>>and in the every alloc function, have own struct data to pass in/out...
>>>>
>

Sorry send you the wrong version, how about this one?



--bp/iNruPH9dso1Pn
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-2.patch"


--bp/iNruPH9dso1Pn--

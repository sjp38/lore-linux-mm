Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 1931D6B0032
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 22:51:38 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 29 Aug 2013 12:37:49 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 4912B2CE804C
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 12:51:31 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7T2pEXu7602674
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 12:51:20 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7T2pN2b014750
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 12:51:25 +1000
Date: Thu, 29 Aug 2013 10:51:22 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/4] mm/sparse: introduce alloc_usemap_and_memmap
Message-ID: <20130829025122.GA451@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20130820160735.b12fe1b3dd64b4dc146d2fa0@linux-foundation.org>
 <CAE9FiQVy2uqLm2XyStYmzxSmsw7TzrB0XDhCRLymnf+L3NPxrA@mail.gmail.com>
 <52142ffe.84c0440a.57e5.02acSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQW1c3-d+iMebRK6JyHCpMt8mjga-TnsfTuVsC1bQZqsYA@mail.gmail.com>
 <52146c58.a3e2440a.0f5a.ffffed8dSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQVWVzO93RM_QT-Qp+5jJUEiw=5OOD_454fCjgQ5p9-b3g@mail.gmail.com>
 <521600cc.22ab440a.2703.53f1SMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQXrpZU8DCFoF6NuaOoqwGFGcQfnHV7vdWWPfyAymCCGnQ@mail.gmail.com>
 <CAE9FiQU34RC+4uLpeza4PAAK-1CWu82WQ=rhaM_NNj_TVv0EMg@mail.gmail.com>
 <CAE9FiQVPmjxCzOCPQWz4=6JwzB-Vn5YMtOEd-G97SvEgoY3RQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQVPmjxCzOCPQWz4=6JwzB-Vn5YMtOEd-G97SvEgoY3RQg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Yinghai,
On Wed, Aug 28, 2013 at 07:42:29PM -0700, Yinghai Lu wrote:
>On Wed, Aug 28, 2013 at 7:34 PM, Yinghai Lu <yinghai@kernel.org> wrote:
>> On Wed, Aug 28, 2013 at 7:18 PM, Yinghai Lu <yinghai@kernel.org> wrote:
>>> please change to function pointer to
>>> void  (*alloc_func)(void *data,
>>>                                  unsigned long pnum_begin,
>>>                                  unsigned long pnum_end,
>>>                                  unsigned long map_count, int nodeid)
>>>
>>> pnum_begin, pnum_end, map_coun, nodeid, should not be in the struct.
>>
>> looks like that is what is your first version did.
>>
>> I updated it a little bit. please check it.
>>
>
>removed more lines.

Thanks for your great work!

The fixed patch looks good to me. If this is the last fix and I can
ignore http://marc.info/?l=linux-mm&m=137774271220239&w=2?

Regards,
Wanpeng Li 

>
>Yinghai


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

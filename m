Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 0C1F26B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 11:21:58 -0400 (EDT)
From: "Pearson, Greg" <greg.pearson@hp.com>
Subject: Re: [PATCH v4] mm/memblock: fix overlapping allocation when
 doubling reserved array
Date: Wed, 20 Jun 2012 15:21:24 +0000
Message-ID: <4FE1EA73.2030300@hp.com>
References: <1340063278-31601-1-git-send-email-greg.pearson@hp.com>
 <20120619151435.10c16aed.akpm@linux-foundation.org>
 <4FE0FE9B.8020401@hp.com> <20120619160001.0c58c7be.akpm@linux-foundation.org>
In-Reply-To: <20120619160001.0c58c7be.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <A20F1A488621CC4496B846142F9F47A0@Compaq.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "tj@kernel.org" <tj@kernel.org>, "hpa@linux.intel.com" <hpa@linux.intel.com>, "shangw@linux.vnet.ibm.com" <shangw@linux.vnet.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>, "yinghai@kernel.org" <yinghai@kernel.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 06/19/2012 05:00 PM, Andrew Morton wrote:
> On Tue, 19 Jun 2012 22:35:08 +0000
> "Pearson, Greg" <greg.pearson@hp.com> wrote:
>
>> On 06/19/2012 04:14 PM, Andrew Morton wrote:
>>> On Mon, 18 Jun 2012 17:47:58 -0600
>>> Greg Pearson <greg.pearson@hp.com> wrote:
>>>
>>>> The __alloc_memory_core_early() routine will ask memblock for a range
>>>> of memory then try to reserve it. If the reserved region array lacks
>>>> space for the new range, memblock_double_array() is called to allocate
>>>> more space for the array. If memblock is used to allocate memory for
>>>> the new array it can end up using a range that overlaps with the range
>>>> originally allocated in __alloc_memory_core_early(), leading to possib=
le
>>>> data corruption.
>>> OK, but we have no information about whether it *does* lead to data
>>> corruption.  Are there workloads which trigger this?  End users who are
>>> experiencing problems?
>>>
>>> See, I (and others) need to work out whether this patch should be
>>> included in 3.5 or even earlier kernels.  To do that we often need the
>>> developer to tell us what the impact of the bug is upon users.  Please
>>> always include this info when fixing bugs.
>> Andrew,
>>
>> I'm currently working on a prototype system that exhibits the data
>> corruption problem when doubling the reserved array while booting the
>> system. This system will be a released product in the future.
> OK.  I guess we can slip this fix into 3.5.  Do you think it should be
> backported?  I guess "yes", as you will probably want to run 3.4 or
> earlier kernels on that machine.
>
Having the fix in 3.4 would be good for us, as we do plan to test on the=20
latest stable kernel.

If there is anything I can do to help with that please let me know.

Thanks

--
Greg=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

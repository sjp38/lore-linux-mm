Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CA60E8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:25:02 -0500 (EST)
Received: by bwz17 with SMTP id 17so5763650bwz.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 15:24:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110307231448.GA2946@spritzera.linux.bs1.fc.nec.co.jp>
References: <1299503155-6210-1-git-send-email-pholasek@redhat.com>
	<1299527214.8493.13263.camel@nimitz>
	<20110307145149.97e6676e.akpm@linux-foundation.org>
	<20110307231448.GA2946@spritzera.linux.bs1.fc.nec.co.jp>
Date: Mon, 7 Mar 2011 18:24:58 -0500
Message-ID: <AANLkTi=NjkQoLQX2ZYxb-oDN7x5TYybe=pMkpOeZDc-Q@mail.gmail.com>
Subject: Re: [PATCH] hugetlb: /proc/meminfo shows data for all sizes of hugepages
From: Eric B Munson <emunson@mgebm.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, anton@redhat.com, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

2011/3/7 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>:
>> >
>> > Could we do something where we keep the default hpage_size looking lik=
e
>> > it does now, but append the size explicitly for the new entries?
>> >
>> > HugePages_Total(1G): =A0 =A0 =A0 2
>> > HugePages_Free(1G): =A0 =A0 =A0 =A01
>> > HugePages_Rsvd(1G): =A0 =A0 =A0 =A01
>> > HugePages_Surp(1G): =A0 =A0 =A0 =A01
>> >
>>
>> Let's not change the existing interface, please.
>>
>> Adding new fields: OK.
>> Changing the way in whcih existing fields are calculated: OKish.
>> Renaming existing fields: not OK.
>
> How about lining up multiple values in each field like this?
>
> =A0HugePages_Total: =A0 =A0 =A0 5 2
> =A0HugePages_Free: =A0 =A0 =A0 =A02 1
> =A0HugePages_Rsvd: =A0 =A0 =A0 =A03 1
> =A0HugePages_Surp: =A0 =A0 =A0 =A01 1
> =A0Hugepagesize: =A0 =A0 =A0 2048 1048576 kB
> =A0...
>
> This doesn't change the field names and the impact for user space
> is still small?
>
> Thanks,
> Naoya
>

I don't like this either, Dave's suggestion impacts userspace the
least, as code that looks for default huge page size pool info will
still find it, but it won't match the sized entries.  Your suggestion
means that I need to change how libhugetlbfs, for instance, parses
meminfo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1465C6B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 11:57:44 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so175750261pac.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 08:57:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ul1si311411pab.19.2016.04.29.08.57.43
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 08:57:43 -0700 (PDT)
From: Dave Hansen <dave.hansen@intel.com>
Subject: Re: [LSF/MM ATTEND][LSF/MM TOPIC] Address range mirroring enhancement
References: <E86EADE93E2D054CBCD4E708C38D364A734D7A73@G01JPEXMBYT01>
 <56D3D0BA.6040209@gmail.com>
 <E86EADE93E2D054CBCD4E708C38D364A734D9220@G01JPEXMBYT01>
Message-ID: <57238476.5050505@intel.com>
Date: Fri, 29 Apr 2016 08:57:42 -0700
MIME-Version: 1.0
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A734D9220@G01JPEXMBYT01>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>
Cc: Tony Luck <tony.luck@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kleen, Andi" <andi.kleen@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, Mel Gorman <mgorman@suse.de>

On 03/01/2016 09:31 PM, Izumi, Taku wrote:
>> > > I'd like to atten LSF/MM 2016 and I'd like to discuss "Address range mirroring" topic.
>> > > The current status of Address range mirroring in Linux is:
>> > >   - bootmem will be allocated from mirroring range
>> > >   - kernel memorry will be allocated from mirroring range
>> > >     by specifying kernelcore=mirror
>> > >
>> > > I think we can enhance Adderss range mirroring more.
>> > > For excample,
>> > >   - The handling of mirrored memory exhaustion case
>> > >   - The option any user memory can be allocated from mirrored memory
>> > >   and so on.

It sounds like there was some good discussions of this at LSF/MM:

	https://lwn.net/Articles/684866/

One thing I wanted to add: There's an Intel platform (Knights Landing
aka Xeon Phi) that has some on-package memory.  It's higher-bandwidth
than normal DRAM, but it shows up as a really slow, remote NUMA node.
Instead of needing to come up with new syscalls for allocating from this
new memory, applications just use the plain old NUMA APIs.

While this doesn't help any of the other issues for mirroring (the
fallback and exhaustion problems), is there a reason we shouldn't use
the NUMA APIs for this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

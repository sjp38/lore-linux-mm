Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE9516B0387
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:34:31 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k190so215151404pgk.8
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:34:31 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a8si10232318ple.118.2017.07.26.06.34.30
        for <linux-mm@kvack.org>;
        Wed, 26 Jul 2017 06:34:31 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH 1/1] mm/hugetlb: Make huge_pte_offset() consistent and document behaviour
References: <20170725154114.24131-1-punit.agrawal@arm.com>
	<20170725154114.24131-2-punit.agrawal@arm.com>
	<20170726085038.GB2981@dhcp22.suse.cz>
	<20170726085325.GC2981@dhcp22.suse.cz>
	<87bmo7jt31.fsf@e105922-lin.cambridge.arm.com>
	<20170726123357.GP2981@dhcp22.suse.cz>
	<20170726124704.GQ2981@dhcp22.suse.cz>
Date: Wed, 26 Jul 2017 14:34:27 +0100
In-Reply-To: <20170726124704.GQ2981@dhcp22.suse.cz> (Michal Hocko's message of
	"Wed, 26 Jul 2017 14:47:04 +0200")
Message-ID: <8760efjp98.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, steve.capper@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, kirill.shutemov@linux.intel.com, Mike Kravetz <mike.kravetz@oracle.com>

Michal Hocko <mhocko@kernel.org> writes:

> On Wed 26-07-17 14:33:57, Michal Hocko wrote:
>> On Wed 26-07-17 13:11:46, Punit Agrawal wrote:
> [...]
>> > I've been running tests from mce-test suite and libhugetlbfs for similar
>> > changes we did on arm64. There could be assumptions that were not
>> > exercised but I'm not sure how to check for all the possible usages.
>> > 
>> > Do you have any other suggestions that can help improve confidence in
>> > the patch?
>> 
>> Unfortunatelly I don't. I just know there were many subtle assumptions
>> all over the place so I am rather careful to not touch the code unless
>> really necessary.
>> 
>> That being said, I am not opposing your patch.
>
> Let me be more specific. I am not opposing your patch but we should
> definitely need more reviewers to have a look. I am not seeing any
> immediate problems with it but I do not see a large improvements either
> (slightly less nightmare doesn't make me sleep all that well ;)). So I
> will leave the decisions to others.

I hear you - I'd definitely appreciate more eyes on the code change and
description.

Thanks for taking a look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

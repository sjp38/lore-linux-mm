Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB2256B02B4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 23:16:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i19so60800608qte.5
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 20:16:45 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 136si14391649qkg.70.2017.07.26.20.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 20:16:45 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm/hugetlb: Make huge_pte_offset() consistent and
 document behaviour
References: <20170725154114.24131-1-punit.agrawal@arm.com>
 <20170725154114.24131-2-punit.agrawal@arm.com>
 <20170726085038.GB2981@dhcp22.suse.cz> <20170726085325.GC2981@dhcp22.suse.cz>
 <87bmo7jt31.fsf@e105922-lin.cambridge.arm.com>
 <20170726123357.GP2981@dhcp22.suse.cz> <20170726124704.GQ2981@dhcp22.suse.cz>
 <8760efjp98.fsf@e105922-lin.cambridge.arm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <9b3b3585-f984-e592-122c-ed23c8558069@oracle.com>
Date: Wed, 26 Jul 2017 20:16:31 -0700
MIME-Version: 1.0
In-Reply-To: <8760efjp98.fsf@e105922-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, steve.capper@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, kirill.shutemov@linux.intel.com

On 07/26/2017 06:34 AM, Punit Agrawal wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
>> On Wed 26-07-17 14:33:57, Michal Hocko wrote:
>>> On Wed 26-07-17 13:11:46, Punit Agrawal wrote:
>> [...]
>>>> I've been running tests from mce-test suite and libhugetlbfs for similar
>>>> changes we did on arm64. There could be assumptions that were not
>>>> exercised but I'm not sure how to check for all the possible usages.
>>>>
>>>> Do you have any other suggestions that can help improve confidence in
>>>> the patch?
>>>
>>> Unfortunatelly I don't. I just know there were many subtle assumptions
>>> all over the place so I am rather careful to not touch the code unless
>>> really necessary.
>>>
>>> That being said, I am not opposing your patch.
>>
>> Let me be more specific. I am not opposing your patch but we should
>> definitely need more reviewers to have a look. I am not seeing any
>> immediate problems with it but I do not see a large improvements either
>> (slightly less nightmare doesn't make me sleep all that well ;)). So I
>> will leave the decisions to others.
> 
> I hear you - I'd definitely appreciate more eyes on the code change and
> description.

I like the change in semantics for the routine.  Like you, I examined all
callers of huge_pte_offset() and it appears that they will not be impacted
by your change.

My only concern is that arch specific versions of huge_pte_offset, may
not (yet) follow the new semantic.  Someone could potentially introduce
a new huge_pte_offset call and depend on the new 'documented' semantics.
Yet, an unmodified arch specific version of huge_pte_offset might have
different semantics.  I have not reviewed all the arch specific instances
of the routine to know if this is even possible.  Just curious if you
examined these, or perhaps you think this is not an issue?

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

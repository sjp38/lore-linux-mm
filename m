Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6B157280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 12:52:09 -0400 (EDT)
Received: by igrv9 with SMTP id v9so80518710igr.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 09:52:09 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id 63si9209909iog.101.2015.07.03.09.52.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 09:52:08 -0700 (PDT)
Received: by igrv9 with SMTP id v9so80518554igr.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 09:52:08 -0700 (PDT)
Message-ID: <5596BDB6.5060708@gmail.com>
Date: Fri, 03 Jul 2015 12:52:06 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com> <20150702072621.GB12547@dhcp22.suse.cz> <20150702160341.GC9456@thunk.org> <55956204.2060006@gmail.com> <20150703144635.GE9456@thunk.org> <5596A20F.6010509@gmail.com> <20150703150117.GA3688@dhcp22.suse.cz> <5596A42F.60901@gmail.com> <20150703164944.GG9456@thunk.org>
In-Reply-To: <20150703164944.GG9456@thunk.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 2015-07-03 12:49 PM, Theodore Ts'o wrote:
> On Fri, Jul 03, 2015 at 11:03:11AM -0400, nick wrote:
>>
>> The reason I am doing this is Ted is trying to find a bug that I
>> fixed in order to prove to Greg Kroah Hartman I have
>> changed. Otherwise I would be pushing this through the drm
>> maintainer(s).
> 
> I am trying to determine if you have changed.  Your comment justifying
> your lack of testing because "it's hard to test" is ample evidence
> that you have *not* changed.
> 
> Simply coming up with a commit that happens to be correct is a
> necessary, but not sufficient condition.  Especially when you feel
> that you need to send dozens of low-value patches and hope that one of
> them is correct, and then use that as "proof".  It's the attitude
> which is problem, not whether or not you can manage to come up with a
> correct patch.
> 
> I've described to you what you need to do in order to demonstrate that
> you have the attitude and inclinations in order to be a kernel
> developer that a maintainer can trust as being capable of authoring a
> patch that doesn't create more problems than whatever benefits it
> might have.  I respectfully ask that you try to work on that, and stop
> bothering me (and everyone else).
> 
> Best regards,
> 
> 						- Ted
> 
Ted,
I agree with you 100 percent. The reason I can't test this is I don't have the
hardware otherwise I would have tested it by now.
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

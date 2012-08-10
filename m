Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 0690B6B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 08:07:13 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so1787671vcb.14
        for <linux-mm@kvack.org>; Fri, 10 Aug 2012 05:07:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120810094825.GA1440@dhcp22.suse.cz>
References: <CAJd=RBB=jKD+9JcuBmBGC8R8pAQ-QoWHexMNMsXpb9zV548h5g@mail.gmail.com>
	<20120803133235.GA8434@dhcp22.suse.cz>
	<20120810094825.GA1440@dhcp22.suse.cz>
Date: Fri, 10 Aug 2012 20:07:12 +0800
Message-ID: <CAJd=RBDA3pLYDpryxafx6dLoy7Fk8PmY-EFkXCkuJTB2ywfsjA@mail.gmail.com>
Subject: Re: [patch] hugetlb: correct page offset index for sharing pmd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 10, 2012 at 5:48 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 03-08-12 15:32:35, Michal Hocko wrote:
>> On Fri 03-08-12 20:56:45, Hillf Danton wrote:
>> > The computation of page offset index is open coded, and incorrect, to
>> > be used in scanning prio tree, as huge page offset is required, and is
>> > fixed with the well defined routine.
>>
>> I guess that nobody reported this because if someone really wants to
>> share he will use aligned address for mmap/shmat and so the index is 0.
>> Anyway it is worth fixing. Thanks for pointing out!
>
> I have looked at the code again and I don't think there is any problem
> at all. vma_prio_tree_foreach understands page units so it will find
> appropriate svmas.
> Or am I missing something?

Well, what if another case of vma_prio_tree_foreach used by hugetlb
is correct?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

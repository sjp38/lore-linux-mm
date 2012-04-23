Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id C755A6B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 12:40:20 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so4439587lbb.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 09:40:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F93D0D9.3050901@redhat.com>
References: <1334356721-9009-1-git-send-email-yinghan@google.com>
	<20120420151143.433c514e.akpm@linux-foundation.org>
	<4F93D0D9.3050901@redhat.com>
Date: Mon, 23 Apr 2012 09:40:18 -0700
Message-ID: <CALWz4izsOs_-gjR7VV7CyFpzqTQB7sTB4jr7WFBDUXLodZA5yQ@mail.gmail.com>
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>

On Sun, Apr 22, 2012 at 2:35 AM, Avi Kivity <avi@redhat.com> wrote:
> On 04/21/2012 01:11 AM, Andrew Morton wrote:
>> On Fri, 13 Apr 2012 15:38:41 -0700
>> Ying Han <yinghan@google.com> wrote:
>>
>> > The mmu_shrink() is heavy by itself by iterating all kvms and holding
>> > the kvm_lock. spotted the code w/ Rik during LSF, and it turns out we
>> > don't need to call the shrinker if nothing to shrink.
>> >
>>
>> We should probably tell the kvm maintainers about this ;)
>>
>
>
> Andrew, I see you added this to -mm. =A0First, it should go through the
> kvm tree. =A0Second, unless we misunderstand something, the patch does
> nothing, so I don't think it should be added at all.

Avi, does this patch help the case as you mentioned above, where kvm
module is loaded but no virtual machines are present ? Why we have to
walk the empty while holding the spinlock?

--Ying

>
> --
> error compiling committee.c: too many arguments to function
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

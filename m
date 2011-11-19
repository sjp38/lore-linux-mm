Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1826B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:27:03 -0500 (EST)
Received: by wwf10 with SMTP id 10so5233836wwf.26
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 19:26:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111118113946.6563fd08.akpm@linux-foundation.org>
References: <CAJd=RBC+p8033bHNfP=WQ2SU1Y1zRpj+FEi9FdjuFKkjF_=_iA@mail.gmail.com>
	<20111118150742.GA23223@tiehlicka.suse.cz>
	<CAJd=RBCOK9tis-bF87Csn70miRDqLtCUiZmDH2hnc8i_9+KtNw@mail.gmail.com>
	<20111118161128.GC23223@tiehlicka.suse.cz>
	<20111118113946.6563fd08.akpm@linux-foundation.org>
Date: Sat, 19 Nov 2011 11:26:59 +0800
Message-ID: <CAJd=RBCem0hw8w1ehNZnzb6OMqn1xsqT9yczgDag0ydp9mavCw@mail.gmail.com>
Subject: Re: [PATCH] hugetlb: detect race if fail to COW
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sat, Nov 19, 2011 at 3:39 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 18 Nov 2011 17:11:28 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
>
>> On Fri 18-11-11 23:23:12, Hillf Danton wrote:
>> > On Fri, Nov 18, 2011 at 11:07 PM, Michal Hocko <mhocko@suse.cz> wrote:
>> > > On Fri 18-11-11 22:04:37, Hillf Danton wrote:
>> > >> In the error path that we fail to allocate new huge page, before tr=
y again, we
>> > >> have to check race since page_table_lock is re-acquired.
>> > >
>> > > I do not think we can race here because we are serialized by
>> > > hugetlb_instantiation_mutex AFAIU. Without this lock, however, we co=
uld
>> > > fall into avoidcopy and shortcut despite the fact that other thread =
has
>> > > already did the job.
>> > >
>> > > The mutex usage is not obvious in hugetlb_cow so maybe we want to be
>> > > explicit about it (either a comment or do the recheck).
>> > >
>> >
>> > Then the following check is unnecessary, no?
>>
>> Hmm, thinking about it some more, I guess we have to recheck because we
>> can still race with page migration. So we need you patch.
>>
>> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
> So we need a new changelog. =C2=A0How does this look?
>
Thanks Andrew and Michal:)

Best regards
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

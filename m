Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id C69BB6B005C
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 14:31:56 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id fy7so2542262vcb.41
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 11:31:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120608141945.4df63d95.akpm@linux-foundation.org>
References: <1338405610-1788-1-git-send-email-pshelar@nicira.com>
	<20120608131045.90708bda.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1206081514130.4213@router.home>
	<CALnjE+rdvdj=XXd7iCYzL_BUGYsLQTM1mYRay+0q2iFxqiDqSw@mail.gmail.com>
	<20120608141945.4df63d95.akpm@linux-foundation.org>
Date: Mon, 11 Jun 2012 11:31:55 -0700
Message-ID: <CALnjE+oS0JptkgEta-ysCLWzW-zEK7NB0rkg3DG-gYnB4MZzoA@mail.gmail.com>
Subject: Re: [Resend PATCH v2] mm: Fix slab->page _count corruption.
From: Pravin Shelar <pshelar@nicira.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, penberg@kernel.org, aarcange@redhat.com, linux-mm@kvack.org, abhide@nicira.com, Jesse Gross <jesse@nicira.com>

On Fri, Jun 8, 2012 at 2:19 PM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Fri, 8 Jun 2012 13:23:56 -0700
> Pravin Shelar <pshelar@nicira.com> wrote:
>
>> On Fri, Jun 8, 2012 at 1:15 PM, Christoph Lameter <cl@linux.com> wrote:
>> > On Fri, 8 Jun 2012, Andrew Morton wrote:
>> >
>> >> OK. __I assume this bug has been there for quite some time.
>> >
>> > Well the huge pages refcount tricks caused the issue.
>> >
>> >> How serious is it? __Have people been reporting it in real workloads?
>> >> How to trigger it? __IOW, does this need -stable backporting?
>> >
>> > Possibly.
>>
>> If this patch is getting back-ported then we shld also do same for
>> 5bf5f03c271907978 (mm: fix slab->page flags corruption) which fixes
>> other issue related to slub =A0and huge page sharing.
>
> Well I don't know if either are getting backported yet.
>
> To decide that we would have to understand the end-user impact of the
> bug(s). =A0Please tell us?
>

We are working on zero copy io over skb in Open-vswitch. thats when we
so this panic when we tried to get_page() over skb linear data
allocated slub. But then I realized that it could potentially affect
other subsystems as well, e.g. xfs and ocfs, which does page struct
updates on slub objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

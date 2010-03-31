Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 82F946B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 23:56:03 -0400 (EDT)
Received: by pzk1 with SMTP id 1so523357pzk.23
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 20:56:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cf18f8341003301836i248d716as8d90c130790194ff@mail.gmail.com>
References: <1269874629-1736-1-git-send-email-lliubbo@gmail.com>
	 <28c262361003291703i5382e342q773ffb16e3324cf5@mail.gmail.com>
	 <alpine.DEB.2.00.1003301128320.24266@router.home>
	 <cf18f8341003301836i248d716as8d90c130790194ff@mail.gmail.com>
Date: Wed, 31 Mar 2010 12:56:00 +0900
Message-ID: <i2s28c262361003302056w9182fa60o4accae49c75e2118@mail.gmail.com>
Subject: Re: [RFC][PATCH] migrate_pages:skip migration between intersect nodes
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org, lee.schermerhorn@hp.com, andi@firstfloor.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2010 at 10:36 AM, Bob Liu <lliubbo@gmail.com> wrote:
> On 3/31/10, Christoph Lameter <cl@linux-foundation.org> wrote:
>> On Tue, 30 Mar 2010, Minchan Kim wrote:
>>
>>> Hi, Bob
>>>
>>> On Mon, Mar 29, 2010 at 11:57 PM, Bob Liu <lliubbo@gmail.com> wrote:
>>> > In current do_migrate_pages(),if from_nodes and to_nodes have some
>>> > intersect nodes,pages in these intersect nodes will also be
>>> > migrated.
>>> > eg. Assume that, from_nodes: 1,2,3,4 to_nodes: 2,3,4,5. Then these
>>> > migrates will happen:
>>> > migrate_pages(4,5);
>>> > migrate_pages(3,4);
>>> > migrate_pages(2,3);
>>> > migrate_pages(1,2);
>>> >
>>> > But the user just want all pages in from_nodes move to to_nodes,
>>> > only migrate(1,2)(ignore the intersect nodes.) can satisfied
>>> > the user's request.
>>> >
>>> > I amn't sure what's migrate_page's semantic.
>>> > Hoping for your suggestions.
>>>
>>> I didn't see 8:migratepages Lee pointed at that time.
>>> The description matches current migrate_pages's behavior exactly.
>>>
>>> I agree Lee's opinion.
>>> Let's wait Christoph's reply what is semantic
>>> and why it doesn't have man page.
>>
>> Manpage is part of numatools.
>>
>> The intended semantic is the preservation of the relative position of th=
e
>> page to the beginning of the node set. If you do not want to preserve th=
e
>> relative position then just move portions of the nodes around.
>>
>
> Hmm.,
> Sorry I still haven't understand your mention :-)
>
> My concern was why move the pages in the intersect nodes.I think skipping
> this migration we can also satisfy the user's request.
> In the above semantic, I =C2=A0haven't got the result.
>

man page said.

"For example if we move from nodes 2-5 to 7,9,12-13 then the preferred mode=
 of
operation is to move pages from 2->7, 3->9, 4->12 and 5->13. However, this
is only posssible if enough memory is available."

If user uses migratepages((1,2,3,4), (2,3,4,5)), He want to move pages
(1->2), (2-3), (3->4), (4-5). It matches with magpage.

But with your suggestion, only (1-2).
I think It doesn't match with man page.

Do you want to add some words to make manpage more clear?

> Thanks!
> --
> Regards,
> -Bob
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

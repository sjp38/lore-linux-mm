Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 090BB6B01FF
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 21:02:35 -0400 (EDT)
Received: by pzk28 with SMTP id 28so1723982pzk.11
        for <linux-mm@kvack.org>; Thu, 15 Apr 2010 18:02:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1004151939310.17800@router.home>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
	 <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>
	 <20100413083855.GS25756@csn.ul.ie>
	 <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>
	 <alpine.DEB.2.00.1004151939310.17800@router.home>
Date: Fri, 16 Apr 2010 09:02:32 +0800
Message-ID: <r2hcf18f8341004151802g2bc338c0sb1e815c0a14e7474@mail.gmail.com>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
Cc: kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 8:41 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Tue, 13 Apr 2010, Bob Liu wrote:
>
>> If move to the next node instead of early return, the relative position =
of the
>> page to the beginning of the node set will be break;
>
> Right.
>

Thanks!
Then would you please acking this patch?  So as mel.

>> (BTW:I am still not very clear about the preservation of the relative
>> position of the
>> page to the beginning of the node set. I think if the user call
>> migrate_pages() with
>> different count of src and dest nodes, the =C2=A0relative position will =
also break.
>> eg. if call migrate_pags() from nodes is node(1,2,3) , dest nodes is
>> just node(3).
>> the current code logical will move pages in node 1, 2 to node 3. this ca=
se the
>> relative position is breaked).
>
> But in that case the user has specified that the set of nodes should be
> compacted during migration and therefore requested what ocurred.
>

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

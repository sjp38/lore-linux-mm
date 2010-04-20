Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3A44B6B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 22:08:28 -0400 (EDT)
Received: by pwi2 with SMTP id 2so3722589pwi.14
        for <linux-mm@kvack.org>; Mon, 19 Apr 2010 19:08:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1004191245250.9855@router.home>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
	 <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>
	 <20100413083855.GS25756@csn.ul.ie>
	 <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>
	 <20100416111539.GC19264@csn.ul.ie>
	 <o2kcf18f8341004160803v9663d602g8813b639024b5eca@mail.gmail.com>
	 <alpine.DEB.2.00.1004161049130.7710@router.home>
	 <m2vcf18f8341004170654tc743e4b0s73a0e234cfdcda93@mail.gmail.com>
	 <alpine.DEB.2.00.1004191245250.9855@router.home>
Date: Tue, 20 Apr 2010 10:08:26 +0800
Message-ID: <w2ucf18f8341004191908v2546cfffo3cc7615802ca1c80@mail.gmail.com>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 1:47 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Sat, 17 Apr 2010, Bob Liu wrote:
>
>> > GFP_THISNODE forces allocation from the node. Without it we will fallback.
>> >
>>
>> Yeah, but I think we shouldn't fallback at this case, what we want is
>> alloc a page
>> from exactly the dest node during migrate_to_node(dest).So I added
>> GFP_THISNODE.
>
> Why would we want that?
>

Because if dest node have no memory, it will fallback to other nodes.
The dest node's fallback nodes may be nodes in nodemask from_nodes.
It maybe make circulation ?.(I am not sure.)

What's more,i think it against the user's request.
The user wants to move pages from from_nodes to to_nodes, if fallback
happened, the pages may be moved to other nodes instead of any node in
nodemask to_nodes.
I am not sure if the user can expect this and accept.

Thanks a lot for your patient reply. :)
-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

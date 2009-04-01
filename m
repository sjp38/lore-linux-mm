Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4DB3C6B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 09:30:31 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so34564wfa.11
        for <linux-mm@kvack.org>; Wed, 01 Apr 2009 06:30:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0904011245130.12751@blonde.anvils>
References: <28c262360903310338k20b8eebbncb86baac9b09e54@mail.gmail.com>
	 <Pine.LNX.4.64.0903311154570.19028@blonde.anvils>
	 <20090401165516.B1EB.A69D9226@jp.fujitsu.com>
	 <Pine.LNX.4.64.0904011245130.12751@blonde.anvils>
Date: Wed, 1 Apr 2009 22:30:58 +0900
Message-ID: <2f11576a0904010630w5ab7aaa6wccf0a9d30b43bced@mail.gmail.com>
Subject: Re: add_to_swap_cache with GFP_ATOMIC ?
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

>> IOW, GFP_ATOMIC on add_to_swap() was introduced accidentally. the reason
>> was old add_to_page_cache() didn't have gfp_mask parameter and we didn't
>> =A0have the reason of changing add_to_swap() behavior.
>> I think it don't have deeply reason and changing GFP_NOIO
>> don't cause regression.
>
> You may well be right: we'll see if you send in a patch to change it.
> But I won't be sending in that patch myself, that's all :)

OK, I'll queue it on my local patch queue. thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1234F6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 23:40:24 -0400 (EDT)
Received: by pzk28 with SMTP id 28so4314500pzk.11
        for <linux-mm@kvack.org>; Sun, 11 Apr 2010 20:40:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <z2u28c262361004112034sc52d79f9ocbcc5a7a3a7279d5@mail.gmail.com>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
	 <z2u28c262361004112034sc52d79f9ocbcc5a7a3a7279d5@mail.gmail.com>
Date: Mon, 12 Apr 2010 11:40:21 +0800
Message-ID: <x2hcf18f8341004112040i91e59882z4d2d663389b4bf60@mail.gmail.com>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mel@csn.ul.ie, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 11:34 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Sat, Apr 10, 2010 at 8:49 PM, Bob Liu <lliubbo@gmail.com> wrote:
>> Since alloc_pages_exact_node() is not for allocate page from
>> exact node but just for removing check of node's valid,
>> rename it to alloc_pages_from_valid_node(). Else will make
>> people misunderstanding.
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>

Thanks!

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

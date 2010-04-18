Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BA0E06B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 17:19:15 -0400 (EDT)
Message-ID: <4BCB780C.1030001@kernel.org>
Date: Mon, 19 Apr 2010 06:22:20 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>	 <4BC65237.5080408@kernel.org>	 <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>	 <4BC6BE78.1030503@kernel.org>	 <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>	 <4BC6CB30.7030308@kernel.org>	 <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>	 <4BC6E581.1000604@kernel.org>	 <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>	 <4BC6FBC8.9090204@kernel.org>	 <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com>	 <alpine.DEB.2.00.1004161105120.7710@router.home> <1271606079.2100.159.camel@barrios-desktop>
In-Reply-To: <1271606079.2100.159.camel@barrios-desktop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/19/2010 12:54 AM, Minchan Kim wrote:
>> alloc_pages is the same as alloc_pages_any_node so why have it?
> 
> I don't want to force using '_node' postfix on UMA users.
> Maybe they don't care getting page from any node and event don't need to
> know about _NODE_. 

Yeah, then, remove alloc_pages_any_node().  I can't really see the
point of any_/exact_node.  alloc_pages() and alloc_pages_node() are
fine and in line with other functions.  Why change it?

>> Why remove it? If you want to get rid of -1 handling then check all the
> 
> alloc_pages_node have multiple meaning as you said. So some of users
> misuses that API. I want to clear intention of user.

The name is fine.  Just clean up the users and make the intended usage
clear in documentation and implementation (ie. trigger a big fat
warning) and make all the callers use named constants instead of -1
for special meanings.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

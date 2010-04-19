Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0CFAB6B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 18:26:05 -0400 (EDT)
Message-ID: <4BCCD8BD.1020307@kernel.org>
Date: Tue, 20 Apr 2010 07:27:09 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>  <4BC65237.5080408@kernel.org>  <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>  <4BC6BE78.1030503@kernel.org>  <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>  <4BC6CB30.7030308@kernel.org>  <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>  <4BC6E581.1000604@kernel.org>  <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>  <4BC6FBC8.9090204@kernel.org>  <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com>  <alpine.DEB.2.00.1004161105120.7710@router.home> <1271606079.2100.159.camel@barrios-desktop> <alpine.DEB.2.00.1004191235160.9855@router.home>
In-Reply-To: <alpine.DEB.2.00.1004191235160.9855@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Christoph.

On 04/20/2010 02:38 AM, Christoph Lameter wrote:
> alloc_pages_exact_node results in more confusion because it does suggest
> that fallback to other nodes is not allowed.

I can't see why alloc_pages_exact_node() exists at all.  It's in the
mainline and if you look at the difference between alloc_pages_node()
and alloc_pages_exact_node(), it's almost silly.  :-(

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

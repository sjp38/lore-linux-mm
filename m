Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9856B0038
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 15:40:49 -0400 (EDT)
Received: by mail-ea0-f178.google.com with SMTP id a15so4499478eae.23
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 12:40:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y41si9762134eel.104.2014.03.11.12.40.47
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 12:40:48 -0700 (PDT)
Date: Tue, 11 Mar 2014 14:43:53 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
Message-ID: <20140311184353.GA10764@redhat.com>
References: <1387327369-18806-1-git-send-email-bob.liu@oracle.com>
 <20140131123352.a3da2a1dee32d79ad1f6af9f@linux-foundation.org>
 <530A4CBE.5090305@oracle.com>
 <6B2BA408B38BA1478B473C31C3D2074E2F6DBA97C6@SV-EXCHANGE1.Corp.FC.LOCAL>
 <5314A9E9.6090802@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5314A9E9.6090802@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "walken@google.com" <walken@google.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "stable@kernel.org" <stable@kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, Bob Liu <bob.liu@oracle.com>

On Mon, Mar 03, 2014 at 05:12:25PM +0100, Vlastimil Babka wrote:

 > >> On 01/31/2014 03:33 PM, Andrew Morton wrote:
 > >>> On Wed, 18 Dec 2013 08:42:49 +0800 Bob Liu<lliubbo@gmail.com>  wrote:
 > >>>
 > >>>>> This BUG_ON() was triggered when called from try_to_unmap_cluster()
 > >>>>> which didn't lock the page.
 > >>>>> And it's safe to mlock_vma_page() without PageLocked, so this patch
 > >>>>> fix this issue by removing that BUG_ON() simply.
 > >>>>>
 > >>> This patch doesn't appear to be going anywhere, so I will drop it.
 > >>> Please let's check to see whether the bug still exists and if so,
 > >>> start another round of bugfixing.
 > >>
 > >> This bug still happens on the latest -next kernel.
 > >
 > > Yeah, I recognized it. I'm preparing new patch. Thanks.
 > 
 > What will be your approach? After we had the discussion some month ago 
 > about m(un)lock vs migration I've concluded that there is no race that 
 > page lock helps, and removing the BUG_ON() would be indeed correct. Just 
 > needs to be correctly explained and documentation updated as well.

This is not just a -next problem btw, I just hit this in 3.14-rc6

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

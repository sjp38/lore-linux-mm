Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1C16B0035
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 21:44:30 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so663364wgh.19
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 18:44:29 -0800 (PST)
Received: from mail-ee0-x230.google.com (mail-ee0-x230.google.com [2a00:1450:4013:c00::230])
        by mx.google.com with ESMTPS id ge7si42898wic.56.2014.01.07.18.44.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 18:44:29 -0800 (PST)
Received: by mail-ee0-f48.google.com with SMTP id e49so399649eek.7
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 18:44:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52CC16DC.9070308@suse.cz>
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>
	<52B11765.8030005@oracle.com>
	<52b120a5.a3b2440a.3acf.ffffd7c3SMTPIN_ADDED_BROKEN@mx.google.com>
	<52B166CF.6080300@suse.cz>
	<52b1699f.87293c0a.75d1.34d3SMTPIN_ADDED_BROKEN@mx.google.com>
	<20131218134316.977d5049209d9278e1dad225@linux-foundation.org>
	<52C71ACC.20603@oracle.com>
	<CA+55aFzDcFyyXwUUu5bLP3fsiuzxU7VPivpTPHgp8smvdTeESg@mail.gmail.com>
	<52C74972.6050909@suse.cz>
	<CA+55aFzq1iQqddGo-m=vutwMYn5CPf65Ergov5svKR4AWC3rUQ@mail.gmail.com>
	<6B2BA408B38BA1478B473C31C3D2074E2BF812BC82@SV-EXCHANGE1.Corp.FC.LOCAL>
	<52CC16DC.9070308@suse.cz>
Date: Wed, 8 Jan 2014 10:44:28 +0800
Message-ID: <CA+55aFzCdGR+cNkvBiwmpgnOwFrVD+K9t4JJnFOL0FE-EtFMwQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, Nick Piggin <npiggin@suse.de>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, Jan 7, 2014 at 11:01 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>
> So here's a patch that if accepted should replace the removal of BUG_ON patch in
> -mm tree: http://ozlabs.org/~akpm/mmots/broken-out/mm-remove-bug_on-from-mlock_vma_page.patch
>
> The idea is that try_to_unmap_cluster() will try locking the page
> for mlock, and just leave it alone if lock cannot be obtained. Again
> that's not fatal, as eventually something will encounter and mlock the page.

This looks sane to me. Andrew?

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

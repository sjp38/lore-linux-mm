Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 8032F6B002B
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 10:58:17 -0400 (EDT)
Received: by qchj9 with SMTP id j9so536096qch.9
        for <linux-mm@kvack.org>; Wed, 25 Jul 2012 07:58:16 -0700 (PDT)
Message-ID: <501009AB.4070408@gmail.com>
Date: Wed, 25 Jul 2012 10:58:51 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 v5][resend] tmpfs: interleave the starting node of
 /dev/shmem
References: <1341845199-25677-1-git-send-email-nzimmer@sgi.com> <1341845199-25677-2-git-send-email-nzimmer@sgi.com> <1341845199-25677-3-git-send-email-nzimmer@sgi.com> <20120723105819.GA4455@mwanda> <500DA581.1020602@sgi.com> <alpine.LSU.2.00.1207242048580.9334@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1207242048580.9334@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Nathan Zimmer <nzimmer@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dan Carpenter <dan.carpenter@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@gmail.com

> Please, what's wrong with the patch below, to replace the current
> two or three?  I don't have real NUMA myself: does it work?
> If it doesn't work, can you see why not?

It works. It doesn't match my preference. but I don't want block your way.
this area is maintained you. please go ahead.

at least, inode bias is better than random.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

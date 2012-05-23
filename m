Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 302106B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:04:09 -0400 (EDT)
Message-ID: <4FBD4292.9020907@redhat.com>
Date: Wed, 23 May 2012 16:03:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tmpfs not interleaving properly
References: <74F10842A85F514CA8D8C487E74474BB2C1597@P-EXMB1-DC21.corp.sgi.com>
In-Reply-To: <74F10842A85F514CA8D8C487E74474BB2C1597@P-EXMB1-DC21.corp.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On 05/23/2012 09:28 AM, Nathan Zimmer wrote:
>
> When tmpfs has the memory policy interleaved it always starts allocating at each file at node 0.
> When there are many small files the lower nodes fill up disproportionately.
> My proposed solution is to start a file at a randomly chosen node.
>
> Cc: Christoph Lameter<cl@linux.com>
> Cc: Nick Piggin<npiggin@gmail.com>
> Cc: Hugh Dickins<hughd@google.com>
> Cc: Lee Schermerhorn<lee.schermerhorn@hp.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Nathan T Zimmer<nzimmer@sgi.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

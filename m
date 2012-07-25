Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 16E2F6B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 12:15:50 -0400 (EDT)
Date: Wed, 25 Jul 2012 11:15:47 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: Re: [PATCH 2/2 v5][resend] tmpfs: interleave the starting node of
	/dev/shmem
Message-ID: <20120725161547.GA27993@gulag1.americas.sgi.com>
References: <1341845199-25677-1-git-send-email-nzimmer@sgi.com> <1341845199-25677-2-git-send-email-nzimmer@sgi.com> <1341845199-25677-3-git-send-email-nzimmer@sgi.com> <20120723105819.GA4455@mwanda> <500DA581.1020602@sgi.com> <alpine.LSU.2.00.1207242048580.9334@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207242048580.9334@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Nathan Zimmer <nzimmer@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dan Carpenter <dan.carpenter@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jul 24, 2012 at 09:38:21PM -0700, Hugh Dickins wrote:
> 
> I'm glad Andrew took out the stable Cc: 
Actually I did that.  I have a habit of thinking about performance issues as
bugs and that is not always the case.

> Please, what's wrong with the patch below, to replace the current
> two or three?  I don't have real NUMA myself: does it work?
Yes it works and spreads quite nicely. 

> Nathan, I've presumptuously put in your signoff, because
> you generally seemed happy to incorporate suggestions made.
I am always grateful for suggestions, advise, and help.

Nate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

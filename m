Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 686835F0001
	for <linux-mm@kvack.org>; Thu,  9 Apr 2009 10:17:43 -0400 (EDT)
Message-ID: <49DE038B.2060107@redhat.com>
Date: Thu, 09 Apr 2009 10:17:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: move the scan_unevictable_pages sysctl to the vm
 table
References: <1239270133.7647.213.camel@twins>
In-Reply-To: <1239270133.7647.213.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "lee.schermerhorn" <lee.schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> Subject: mm: move the scan_unevictable_pages sysctl to the vm table
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Thu Apr 09 11:38:45 CEST 2009
>
> vm knobs should go in the vm table. Probably too late for randomize_va_space
> though.
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>   
Dunno if the merge error is mine or someone else's or if
we should all blame patch, but ...

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 538DA6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 09:11:04 -0500 (EST)
Message-ID: <4B9110ED.5000703@redhat.com>
Date: Fri, 05 Mar 2010 09:10:53 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap: Fix Bugzilla Bug #5493
References: <20100305093834.GG17078@lisa.in-ulm.de>
In-Reply-To: <20100305093834.GG17078@lisa.in-ulm.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <lk@c--e.de>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/05/2010 04:38 AM, Christian Ehrhardt wrote:
>
> Hi,
>
> this patch fixes bugzilla Bug
>
>          http://bugzilla.kernel.org/show_bug.cgi?id=5493
>
> This bug describes a search complexity failure in rmap if a single
> anon_vma has a huge number of vmas associated with it.
>
> The patch makes the vma prio tree code somewhat more reusable and then uses
> that to replace the linked list of vmas in an anon_vma with a prio_tree.

Your patch will not apply against a current -mm, because it
conflicts with my anon_vma linking patches (which attacks
another "rmap walks too many vmas" failure mode).

Please rediff your patch against the latest -mm tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

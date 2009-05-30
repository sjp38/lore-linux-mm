Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 554E16B00D9
	for <linux-mm@kvack.org>; Sat, 30 May 2009 13:21:29 -0400 (EDT)
Date: Sat, 30 May 2009 10:21:27 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 3/5] Apply the PG_sensitive flag to audit subsystem
In-Reply-To: <20090520185005.GC10756@oblivion.subreption.com>
Message-ID: <alpine.LFD.2.01.0905301020260.3435@localhost.localdomain>
References: <20090520185005.GC10756@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, faith@redhat.com
List-ID: <linux-mm.kvack.org>



On Wed, 20 May 2009, Larry H. wrote:
>
> +	if (!(gfp_mask & GFP_SENSITIVE))
> +		gfp_mask |= GFP_SENSITIVE;

WTF?

Why is this different from just "gfp_mask |= GFP_SENSITIVE;"

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

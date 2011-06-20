Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B5A2E6B0082
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 07:21:03 -0400 (EDT)
Date: Mon, 20 Jun 2011 07:21:00 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] REPOST: Memory tracking for physical machine migration
Message-ID: <20110620112100.GB19720@infradead.org>
References: <20110610231850.6327.24452.sendpatchset@localhost.localdomain>
 <20110611075516.GA7745@infradead.org>
 <AC1B83CE65082B4DBDDB681ED2F6B2EF12E044@EXHQ.corp.stratus.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AC1B83CE65082B4DBDDB681ED2F6B2EF12E044@EXHQ.corp.stratus.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paradis, James" <James.Paradis@stratus.com>
Cc: linux-mm@kvack.org

On Tue, Jun 14, 2011 at 02:17:49PM -0400, Paradis, James wrote:
> Okay, then, help me out here.  What would it take for this to be accepted?
> Would you like us to incorporate the memory-harvesting code from LKSM as well?

You'll need to actually submit useful code, not just exports that aren't
usable in-tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

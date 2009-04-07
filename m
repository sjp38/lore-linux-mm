Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7150D5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 18:02:09 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EC18E82C2B5
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 18:11:09 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1bzViz41DUmX for <linux-mm@kvack.org>;
	Tue,  7 Apr 2009 18:11:09 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8128182C2B8
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 18:10:58 -0400 (EDT)
Date: Tue, 7 Apr 2009 17:56:28 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] [5/16] POISON: Add support for poison swap entries
In-Reply-To: <20090407215605.GZ17934@one.firstfloor.org>
Message-ID: <alpine.DEB.1.10.0904071755200.12192@qirst.com>
References: <20090407509.382219156@firstfloor.org> <20090407151002.0AA8F1D046E@basil.firstfloor.org> <alpine.DEB.1.10.0904071710500.12192@qirst.com> <20090407215605.GZ17934@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Apr 2009, Andi Kleen wrote:

> On Tue, Apr 07, 2009 at 05:11:26PM -0400, Christoph Lameter wrote:
> >
> > Could you separate the semantic changes to flag checking for migration
>
> You mean to try_to_unmap?

I mean the changes to checking the pte contents for a migratable /
swappable page. Those are significant independent from this patchset and
would be useful to review independently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

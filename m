Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A8BB46B005A
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 19:20:29 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E8C3F82C6E6
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 19:22:51 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id upzv+gwh58fm for <linux-mm@kvack.org>;
	Tue, 22 Sep 2009 19:22:51 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6FA0882C8BF
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 19:13:45 -0400 (EDT)
Date: Tue, 22 Sep 2009 19:07:28 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
In-Reply-To: <363172900909220629j2f5174cbo9fe027354948d37@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0909221904550.24141@V090114053VZO-1>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie>  <20090921174656.GS12726@csn.ul.ie>  <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1>  <20090921180739.GT12726@csn.ul.ie> <4AB85A8F.6010106@in.ibm.com>  <20090922125546.GA25965@csn.ul.ie>
 <4AB8CB81.4080309@in.ibm.com>  <20090922132018.GB25965@csn.ul.ie> <363172900909220629j2f5174cbo9fe027354948d37@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: =?GB2312?B?t8nR1Q==?= <win847@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Sachin Sant <sachinp@in.ibm.com>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Sep 2009, ?? wrote:

> 800KB. How can I config kernel config to reduce kernel size, I want to get
> smaller size  like 500KB.


500kb? That may be a tough call.

> *CONFIG_NETFILTER=y*

Can you drop this one?

Is CONFIG_EMBEDDED set? Maybe I skipped it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

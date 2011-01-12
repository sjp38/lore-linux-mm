Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C81116B00EB
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 15:23:35 -0500 (EST)
Date: Wed, 12 Jan 2011 14:23:25 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Rename struct task variables from p to tsk
In-Reply-To: <20110112201602.GA25957@mgebm.net>
Message-ID: <alpine.DEB.2.00.1101121421490.9271@router.home>
References: <1294845571-11529-1-git-send-email-emunson@mgebm.net> <alpine.DEB.2.00.1101121205120.3053@router.home> <20110112201602.GA25957@mgebm.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jan 2011, Eric B Munson wrote:

> On Wed, 12 Jan 2011, Christoph Lameter wrote:
> > Use t instead of p? Its a local variable after all.
>
> I don't find t any more informative than p.  As a newcomer to most of this code
> informative variable names, even for local variables, is a huge help.

Local variables are short because they are defined close to the point of
use.

tsk is not that informative and the notion of a "task" can refer to
various. However, when I see

	struct task_struct *t;

I know what it refers to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

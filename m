Date: Mon, 19 Feb 2007 20:53:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] free swap space when (re)activating page
In-Reply-To: <45D63445.5070005@redhat.com>
Message-ID: <Pine.LNX.4.64.0702192048150.9934@schroedinger.engr.sgi.com>
References: <45D63445.5070005@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Feb 2007, Rik van Riel wrote:

> What do you think?

Looks good apart from one passage (which just vanished when I tried to 
reply, please post patches as inline text).

It was the portion that modifies shrink_active_list. Why operate
on the pagevec there? The pagevec only contains the leftovers to be 
released from scanning over the temporary inactive list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

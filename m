Date: Fri, 6 Jul 2007 15:34:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memory unplug v7 - introduction
Message-Id: <20070706153401.d1d6bf88.akpm@linux-foundation.org>
In-Reply-To: <20070706181903.428c3713.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070706181903.428c3713.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jul 2007 18:19:03 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> This is a memory unplug base patch set against 2.6.22-rc6-mm1.

Well I stuck these in -mm, but I don't know what they do.  An overall
description of the design would make any review much more effective.

ie: what does it all do, and how does it do it?

Also a description of the test setup and the testing results would be
useful.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

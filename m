Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFDF6B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 06:07:15 -0400 (EDT)
Date: Fri, 29 Jul 2011 11:06:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH -tip 4/5] tracepoints: add tracepoints for pagecache
Message-ID: <20110729100609.GR3010@suse.de>
References: <4E24A61D.4060702@bx.jp.nec.com>
 <4E24A7BB.1040800@bx.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4E24A7BB.1040800@bx.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Fr??d??ric Weisbecker <fweisbec@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "BA, Moussa" <Moussa.BA@numonyx.com>

On Mon, Jul 18, 2011 at 05:38:03PM -0400, Keiichi KII wrote:
> From: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> 
> This patch adds several tracepoints to track pagecach behavior.
> These trecepoints would help us monitor pagecache usage with high resolution.
> 

There are a few spelling mistakes there but what harm. This is an RFC.

Again, it would be really nice if the changelog explained why it was
useful to monitor pagecache usage at this resolution. For example,
I could identify files with high and low hit ratios and conceivably
identify system activity that resulted in page cache being trashed.
However, even in that case, I don't necessarily care which files got
chucked out and that sort of problem can also be seen via fault rates.

Another scenario that may be useful is it could potentially identify an
application bug that was invalidating a portion of a file that was in
fact hot and in use by other processes. I'm sure you have much better
examples that motivated the development of this series :)

The tracepoints themselves look fine.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

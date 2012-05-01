Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 77E096B0081
	for <linux-mm@kvack.org>; Tue,  1 May 2012 14:29:34 -0400 (EDT)
Date: Tue, 1 May 2012 20:29:32 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH RFC 3/3] proc/smaps: show amount of hwpoison pages
Message-ID: <20120501182932.GR27374@one.firstfloor.org>
References: <20120430112903.14137.81692.stgit@zurg> <20120430112910.14137.28935.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120430112910.14137.28935.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Mon, Apr 30, 2012 at 03:29:11PM +0400, Konstantin Khlebnikov wrote:
> This patch adds line "HWPoinson: <size> kB" into /proc/pid/smaps if
> CONFIG_MEMORY_FAILURE=y and some HWPoison pages were found.
> This may be useful for searching applications which use a broken memory.

Makes sense. The kernel will log the process names, but it can be useful to
look for it after the fact to get a more complete picture of the state
of the machine.

Acked-by: Andi Kleen <ak@linux.intel.com>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

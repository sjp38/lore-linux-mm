Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BEEF68D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 09:12:37 -0500 (EST)
Date: Tue, 1 Mar 2011 15:12:30 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH 00/00]Remove one to many n's in a word.
In-Reply-To: <1298781250-2718-17-git-send-email-justinmattock@gmail.com>
Message-ID: <alpine.LNX.2.00.1103011507120.32580@pobox.suse.cz>
References: <1298781250-2718-1-git-send-email-justinmattock@gmail.com> <1298781250-2718-17-git-send-email-justinmattock@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Justin P. Mattock" <justinmattock@gmail.com>
Cc: linux-kernel@vger.kernel.org, Vinod Koul <vinod.koul@intel.com>, Dan Williams <dan.j.williams@intel.com>, Wim Van Sebroeck <wim@iguana.be>, linux-watchdog@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, Alan Stern <stern@rowland.harvard.edu>, linux-usb@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Eric Paris <eparis@redhat.com>, John McCutchan <john@johnmccutchan.com>, Robert Love <rlove@rlove.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

On Sat, 26 Feb 2011, Justin P. Mattock wrote:

> The Patch below removes one to many "n's" in a word.. 

Hi Justin,

I have applied all the patches from the series which were not present in 
linux-next as of today (in a squashed-together form, no need to have 
separated commits for such cosmetic changes).

I'd suggest that, unless any subsystem maintainer explicitly states 
otherwise, you submit all such similar changes justo to trivial@kernel.org 
(and perhaps CC LKML). I propose this because:

- I believe most maintainers don't care about these changes and don't need 
  to be bothered
- it reduces annoying mail traffic (tens of mails because such 
  nano-change)
- it reduces the trivial tree maintainership load, as I don't have to wait 
  and cross-check which maintainer has applied which bits and which ones 
  were not picked up

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

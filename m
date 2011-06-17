Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 18D0D6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 16:41:48 -0400 (EDT)
Date: Fri, 17 Jun 2011 15:41:45 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Some weirdness with slub in 3.0-rc*
In-Reply-To: <4DFBB94A.7030604@redhat.com>
Message-ID: <alpine.DEB.2.00.1106171534020.10158@router.home>
References: <4DFBB94A.7030604@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@redhat.com>
Cc: penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org

On Fri, 17 Jun 2011, Josef Bacik wrote:

> I started noticing that when I rmmod'ed btrfs after running a stress
> test on it that it would complain about objects still left on a couple
> of it's slab's.  I git bisect'ed it but it wasn't coming out right, and
> I just ran the test again with slab instead of slub and it works out
> fine.  Does this sound familiar to anyone?  I can try and bisect it
> down, but the test takes like 30 minutes to reproduce (thankfully I can
> reproduce this every time), so it's going to take a little bit if it
> doesn't ring anybodies bells.  Thanks,

No does not sound familiar. If its some sort of sporadic issue then its
difficult to establish causation. Slub logs information about the objects
to the syslog. Could you post the output? The output will be more detailed
if you run with slub debugging on (pass slub_debug on the kernel command
line).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

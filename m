Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 1680A6B004D
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 17:38:38 -0500 (EST)
Date: Wed, 7 Nov 2012 17:38:30 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] tmpfs: fix shmem_getpage_gfp VM_BUG_ON
Message-ID: <20121107223830.GA12561@redhat.com>
References: <alpine.LNX.2.00.1210242121410.1697@eggly.anvils>
 <20121101191052.GA5884@redhat.com>
 <alpine.LNX.2.00.1211011546090.19377@eggly.anvils>
 <20121101232030.GA25519@redhat.com>
 <alpine.LNX.2.00.1211011627120.19567@eggly.anvils>
 <20121102014336.GA1727@redhat.com>
 <alpine.LNX.2.00.1211021606580.11106@eggly.anvils>
 <alpine.LNX.2.00.1211051729590.963@eggly.anvils>
 <20121106135402.GA3543@redhat.com>
 <alpine.LNX.2.00.1211061521230.6954@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211061521230.6954@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 06, 2012 at 03:48:20PM -0800, Hugh Dickins wrote:
 
 > > ------------[ cut here ]------------
 > > WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
 > > Hardware name: 2012 Client Platform
 > > Pid: 21798, comm: trinity-child4 Not tainted 3.7.0-rc4+ #54
 > 
 > That's the very same line number as in your original report, despite
 > the long comment which the patch adds.  Are you sure that kernel was
 > built with the patch in?

I just changed the code by hand, and opted not to paste the comment in.

It is plausible that I built that kernel and forgot to reboot into it,
but I'm 99.9% sure that that wasn't the case.

Unfortunatly I can't check immediately, as that machine for reasons
unknown no longer wants to get past the BIOS POST check.

I'll see if I can reproduce it on a different test box until I get
that one back up.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

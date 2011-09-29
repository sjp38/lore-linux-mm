Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0D3159000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 10:12:01 -0400 (EDT)
Date: Thu, 29 Sep 2011 09:11:54 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
In-Reply-To: <30918.1317257024@turing-police.cc.vt.edu>
Message-ID: <alpine.DEB.2.00.1109290911080.9382@router.home>
References: <20110927175453.GA3393@albatros> <20110927175642.GA3432@albatros> <20110927193810.GA5416@albatros> <alpine.DEB.2.00.1109271459180.13797@router.home> <alpine.DEB.2.00.1109271328151.24402@chino.kir.corp.google.com> <alpine.DEB.2.00.1109271546320.13797@router.home>
            <1317241905.16137.516.camel@nimitz> <30918.1317257024@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Vasiliy Kulikov <segoon@openwall.com>, kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Wed, 28 Sep 2011, Valdis.Kletnieks@vt.edu wrote:

> > We could also give the imprecise numbers to unprivileged
> > users and let privileged ones see the page-level ones.
>
> That also sounds like a good idea.

Uhh... Another source of confusions for the uninitiated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

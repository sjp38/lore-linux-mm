Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D7CAE6B0082
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 00:36:54 -0500 (EST)
Date: Thu, 14 Jan 2010 05:36:34 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/6] NOMMU: Fix SYSV SHM for NOMMU
Message-ID: <20100114053634.GA15972@ZenIV.linux.org.uk>
References: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
 <23917.1262988613@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23917.1262988613@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: vapier@gentoo.org, lethal@linux-sh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 08, 2010 at 10:10:13PM +0000, David Howells wrote:
> David Howells <dhowells@redhat.com> wrote:
> 
> > Put it back conditionally on CONFIG_MMU=n.
> 
> Seems I forgot to put in the conditional bits.  Revised patch attached.

Series looks sane...  ACK on the entire bunch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

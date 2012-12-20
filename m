Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5C9636B0068
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 20:00:40 -0500 (EST)
Date: Wed, 19 Dec 2012 17:00:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] Add the values related to buddy system for filtering
 free pages.
Message-Id: <20121219170038.f7b260c3.akpm@linux-foundation.org>
In-Reply-To: <878v8ty200.fsf@xmission.com>
References: <20121210103913.020858db777e2f48c59713b6@mxc.nes.nec.co.jp>
	<20121219161856.e6aa984f.akpm@linux-foundation.org>
	<878v8ty200.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, linux-kernel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org

On Wed, 19 Dec 2012 16:57:03 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > Is there any way in which we can move some of this logic into the
> > kernel?  In this case, add some kernel code which uses PageBuddy() on
> > behalf of makedumpfile, rather than replicating the PageBuddy() logic
> > in userspace?
> 
> All that exists when makedumpfile runs is a core file.  So it would have
> to be something like a share library that builds with the kernel and
> then makedumpfile loads.

Can we omit free pages from that core file?

And/or add a section to that core file which flags free pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

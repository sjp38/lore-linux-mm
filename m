Date: Fri, 16 Mar 2001 14:12:34 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [PATCH/RFC] fix missing tlb flush on x86 smp+pae
Message-ID: <20010316141234.B1805@pcep-jamie.cern.ch>
References: <Pine.LNX.4.30.0103151438140.16542-100000@today.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.30.0103151438140.16542-100000@today.toronto.redhat.com>; from bcrl@redhat.com on Thu, Mar 15, 2001 at 02:50:50PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ben LaHaise wrote:
> Below is a patch for 2.4 (it's against 2.4.2-ac20) that fixes a case where
> pmd_alloc could install a new entry without causing a tlb flush on other
> CPUs.  This was fatal with PAE because the CPU caches the top level of the
> page tables, which was showing up as an infinite stream of identical page
> faults.

Ew.  Is this the only case where adding a new entry requires a tlb
flush?  It is quite an unusual requirement.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

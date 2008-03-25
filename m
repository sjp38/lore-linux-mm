Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: larger default page sizes...
Date: Tue, 25 Mar 2008 16:49:23 -0700
Message-ID: <1FE6DD409037234FAB833C420AA843ECE9E2CA@orsmsx424.amr.corp.intel.com>
In-reply-to: <20080325.163240.102401706.davem@davemloft.net>
References: <18408.29107.709577.374424@cargo.ozlabs.ibm.com><20080324.211532.33163290.davem@davemloft.net><18408.59112.945786.488350@cargo.ozlabs.ibm.com> <20080325.163240.102401706.davem@davemloft.net>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>, paulus@samba.org
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> > How do I get gcc to use hugepages, for instance?
>
> Implementing transparent automatic usage of hugepages has been
> discussed many times, it's definitely doable and other OSs have
> implemented this for years.
>
> This is what I was implying.

"large" pages, or "super" pages perhaps ... but Linux "huge" pages
seem pretty hard to adapt for generic use by applications.  They
are generally a somewhere between a bit too big (2MB on X86) to
way too big (64MB, 256MB, 1GB or 4GB on ia64) for general use.

Right now they also suffer from making the sysadmin pick at
boot time how much memory to allocate as huge pages (while it
is possible to break huge pages into normal pages, going in
the reverse direction requires a memory defragmenter that
doesn't exist).

Making an application use huge pages as heap may be simple
(just link with a different library to provide with a different
version of malloc()) ... code, stack, mmap'd files are all
a lot harder to do transparently.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

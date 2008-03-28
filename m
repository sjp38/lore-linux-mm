Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: down_spin() implementation
Date: Fri, 28 Mar 2008 14:16:55 -0700
Message-ID: <1FE6DD409037234FAB833C420AA843ECF237C0@orsmsx424.amr.corp.intel.com>
In-reply-to: <20080328124517.GQ16721@parisc-linux.org>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com> <1FE6DD409037234FAB833C420AA843ECE9EB1C@orsmsx424.amr.corp.intel.com> <20080327141508.GL16721@parisc-linux.org> <200803281101.25037.nickpiggin@yahoo.com.au> <20080328124517.GQ16721@parisc-linux.org>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> So it makes little sense to add this to semaphores.  Better to introduce
> a spinaphore, as you say.

> struct {
>   atomic_t cur;
>   int max;
> } ss_t;

Could this API sneak into the bottom of one or the other of
linux/include/{spinlock,semaphore}.h ... or should it get its own
spinaphore.h file?

Or should I follow Alan's earlier advice and keep this as an ia64
only thing (since I'll be the only user).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

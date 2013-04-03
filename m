Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id CADEA6B00A0
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 00:25:42 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx1so682149pab.28
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 21:25:42 -0700 (PDT)
Date: Tue, 2 Apr 2013 21:25:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
In-Reply-To: <20130403041447.GC4611@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com> <alpine.LNX.2.00.1304021600420.22412@eggly.anvils> <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ian Lance Taylor <iant@google.com>, linux-mm@kvack.org

On Wed, 3 Apr 2013, Johannes Weiner wrote:

> The definition of ACCESS_ONCE() relies on gcc's current
> implementation, the users of ACCESS_ONCE() only rely on ACCESS_ONCE()
> being defined.
> 
> Should it ever break you have to either fix it at the implementation
> level or remove/replace the abstraction in its entirety, how does the
> individual callsite matter in this case?
> 

As stated, it doesn't.  I made the comment "for what it's worth" that 
ACCESS_ONCE() doesn't do anything to "prevent the compiler from 
re-fetching" as the changelog insists it does.  I'd much rather it refer 
to gcc's implementation, which we're counting on here, to avoid any 
confusion since I know a couple people have thought that ACCESS_ONCE() 
forces the compiler to load memory onto the stack and that belief is 
completely and utterly wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 84D306B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 19:59:12 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so1130734pbc.16
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 16:59:11 -0700 (PDT)
Date: Wed, 3 Apr 2013 16:59:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
In-Reply-To: <20130403143302.GL1953@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com> <alpine.LNX.2.00.1304021600420.22412@eggly.anvils> <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org> <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com> <20130403045814.GD4611@cmpxchg.org> <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com> <20130403143302.GL1953@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, 3 Apr 2013, Johannes Weiner wrote:

> Who cares about the implementation, we are discussing a user here.
> ACCESS_ONCE() isolates a problem so that the users don't have to think
> about it, that's the whole point of abstraction.  ACCESS_ONCE() is an
> opaque building block that says it prevents the compiler from merging
> and refetching accesses.  That's all we care about right now.
> 

The discussion is about the implementation of ACCESS_ONCE().  Nobody, thus 
far, has said anything about this specific patch other than me when I 
acked it.  I didn't start another thread off this patch because the 
changelog is relying on the comment above ACCESS_ONCE() to say that this 
"prevents the compiler from refetching."  Some have been confused by this 
comment and accept it at face value that it's really preventing the 
compiler from doing something; in reality, it's "using gcc's 
current implementation to prevent refetching."  It's an important 
distinction for anyone who comes away from the comment believing that 
volatile-qualified pointer dereferences are forbidden to be refetched by 
the compiler.

Others have said that I've somehow discouraged its use because its somehow 
an invalid way of preventing gcc from refetching (when I've acked patches 
that do this exact thing in slub!).  I have no idea how anyone could parse 
anything I've said about discouraging its use.  I simply noted that the 
changelog could be reworded to be clearer since we're not relying on any 
standard here but rather a compiler's current implementation.  It was 
never intended to be a long lengthy thread, but the comment I made is 
correct.  I've worked with Paul to make that clearer in the comment so 
that people aren't confused in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

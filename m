Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 9E3D36B00A4
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 01:13:42 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id mc17so643594pbc.0
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 22:13:41 -0700 (PDT)
Date: Tue, 2 Apr 2013 22:13:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
In-Reply-To: <20130403045814.GD4611@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1304022201520.2554@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com> <alpine.LNX.2.00.1304021600420.22412@eggly.anvils> <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org> <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com> <20130403045814.GD4611@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ian Lance Taylor <iant@google.com>, linux-mm@kvack.org

On Wed, 3 Apr 2013, Johannes Weiner wrote:

> > As stated, it doesn't.  I made the comment "for what it's worth" that 
> > ACCESS_ONCE() doesn't do anything to "prevent the compiler from 
> > re-fetching" as the changelog insists it does.
> 
> That's exactly what it does:
> 
> /*
>  * Prevent the compiler from merging or refetching accesses.
> 
> This is the guarantee ACCESS_ONCE() gives, users should absolutely be
> allowed to rely on this literal definition.  The underlying gcc
> implementation does not matter one bit.  That's the whole point of
> abstraction!
> 

The C99 and earlier C standards do not provide any way of "preventing the 
compiler from refetching accesses," and in fact C99 leaves an access to a 
volatile qualified object as implementation defined.  (If you disagree, 
then specify what exactly about ACCESS_ONCE() prevents the compiler from 
doing so.)

I agree that comment is confusing unless you specify that gcc's 
implementation provides that guarantee and I would tend to agree with 
Paul's assessment that the wide majority (all?) of compilers do the same.  
I would hesitate to say positively that gcc will continue to implement 
anything in the future other than what the standard specifies, though.  
But I do agree that the comment is confusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 4 Jun 2007 09:34:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <1180964790.5055.2.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706040922170.23235@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>  <200705312243.20242.ak@suse.de>
 <20070601093803.GE10459@minantech.com>  <200706011221.33062.ak@suse.de>
 <1180718106.5278.28.camel@localhost>  <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
  <1180726713.5278.80.camel@localhost>  <Pine.LNX.4.64.0706011242250.3598@schroedinger.engr.sgi.com>
  <1180731944.5278.146.camel@localhost>  <Pine.LNX.4.64.0706011445380.5009@schroedinger.engr.sgi.com>
 <1180964790.5055.2.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

We have discussed this since you began this work more than a year ago 
after I asked you to do the memory region based approach. More 
documentation will not change the fundamental problems with inode
based policies.

You can likely make the approach less of a catastophe by enhancing the 
shmem tools (ipcs ipcrm) work on page cache files so that the sysadmin can 
see what kind of policies are set on the inodes in memory right now, so 
that any unusual allocation behavior as a result of the crazy semantics 
here can be detected and fixed.

For shmem (even without page cache inode policies) it may be useful to at 
least modify ipcs to show the memory policies and the distribution of the 
pages for shared memory. Frankly the existing shmem numa policy 
implementation is already a grave cause for concern because there are 
weird policies suddenly come into play that the process has never set. To 
have that for the page cache is a nightmare scenario.

Shmem has at least a determinate lifetime (and therefore also a 
determinate lifetime for memory policies attached to shmem) which makes it 
more manageable. Plus it is a kind of ramdisk where you would want to have 
a policy attached to where the ramdisk data should be placed.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

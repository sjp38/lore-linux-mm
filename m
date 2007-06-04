Date: Mon, 4 Jun 2007 10:11:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <1180976571.5055.24.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706041003040.23603@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>  <200705312243.20242.ak@suse.de>
 <20070601093803.GE10459@minantech.com>  <200706011221.33062.ak@suse.de>
 <1180718106.5278.28.camel@localhost>  <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
  <1180726713.5278.80.camel@localhost>  <Pine.LNX.4.64.0706011242250.3598@schroedinger.engr.sgi.com>
  <1180731944.5278.146.camel@localhost>  <Pine.LNX.4.64.0706011445380.5009@schroedinger.engr.sgi.com>
  <1180964790.5055.2.camel@localhost>  <Pine.LNX.4.64.0706040922170.23235@schroedinger.engr.sgi.com>
 <1180976571.5055.24.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jun 2007, Lee Schermerhorn wrote:

> I try to give you the benefit of the doubt that it's my fault for not
> explaining things clearly enough where you're making what appear to me
> as specious arguments--unintentionally, of course.  But your tone just
> keeps getting more strident.  

Yes, we have been discussing this since for more than year now. I am a bit 
irritated that you keep pushing this. In particular none of the concerns 
have been addressed. Its just as raw as it was then.

> > Shmem has at least a determinate lifetime (and therefore also a 
> > determinate lifetime for memory policies attached to shmem) which makes it 
> > more manageable. Plus it is a kind of ramdisk where you would want to have 
> > a policy attached to where the ramdisk data should be placed.
> So, control over the lifetime of the policies is one of your issue.
> Fine, I can deal with that.  Name calling and hyperbole doesn't help.

The other issues will still remain! This is a fundamental change to the 
nature of memory policies. They are no longer under the control of the 
task but imposed from the outside. If one wants to do this then the whole 
scheme of memory policies needs to be reworked and rethought in order to 
be consistent and usable. For example you would need the ability to clear 
a memory policy. And perhaps call this something different in order not to 
cause confusion?

The patchset also changes semantics to deviate from documented behavior. 
The memory policies work on memory ranges *not* on page ranges of files. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

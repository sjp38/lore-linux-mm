Date: Fri, 25 May 2007 09:24:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
In-Reply-To: <1180109165.5730.32.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705250914510.6070@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
 <200705242241.35373.ak@suse.de> <1180040744.5327.110.camel@localhost>
 <Pine.LNX.4.64.0705241417130.31587@schroedinger.engr.sgi.com>
 <1180104952.5730.28.camel@localhost>  <Pine.LNX.4.64.0705250823260.5850@schroedinger.engr.sgi.com>
 <1180109165.5730.32.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007, Lee Schermerhorn wrote:

> True, but shared, mmap'ed file policy does need to be file based, and
> that is my objective.  I merely point out that we can easily add the
> page cache policy as the fall back when a file has no explicit policy.

The problem is that you have not given sufficient reason for the 
modifications. Tru64 compatibility is not a valid reason.

> > Could you separate out a patch that fixes these issues?
> 
> Could do, but does that improve the chances for acceptance of this patch
> set?  If the patch set is accepted, with whatever corrections might be
> required, we get the numa_maps fix.  So, I'm not currently motivated to
> post a separate patch.

The patchset as is is not acceptable since it does not follow the 
standards. The fixes should come first. So you have to do this anyways to 
get the patchset accepted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

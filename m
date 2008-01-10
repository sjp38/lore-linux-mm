Date: Thu, 10 Jan 2008 14:48:35 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 10/10] x86: Unify percpu.h
Message-ID: <20080110134835.GE5886@elte.hu>
References: <20080108211023.923047000@sgi.com> <20080108211025.293924000@sgi.com> <1199906905.9834.101.camel@localhost> <Pine.LNX.4.64.0801091130420.11317@schroedinger.engr.sgi.com> <1199908430.9834.104.camel@localhost> <Pine.LNX.4.64.0801091210300.11709@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801091210300.11709@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 9 Jan 2008, Dave Hansen wrote:
> 
> > Then I really think this particular patch belongs in that other 
> > patch set.  Here, it makes very little sense, and it's on the end 
> > anyway.
> 
> It makes sense in that both percpu_32/64 are very small as a result of 
> earlier patches and so its justifiable to put them together to 
> simplify the next patchset.

i'd agree with this - lets just keep the existing flow of patches 
intact. It's not like the percpu code is in any danger of becoming 
unclean or quirky - it's one of the best-maintained pieces of kernel 
code :)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

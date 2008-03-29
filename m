Date: Sat, 29 Mar 2008 15:06:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/9] Pageflags: Get rid of FLAGS_RESERVED
Message-Id: <20080329150630.21019399.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0803291321020.26338@schroedinger.engr.sgi.com>
References: <20080318181957.138598511@sgi.com>
	<20080318182035.197900850@sgi.com>
	<20080328011240.fae44d52.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0803281148110.17920@schroedinger.engr.sgi.com>
	<20080328115919.12c0445b.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0803281159250.18120@schroedinger.engr.sgi.com>
	<20080328122313.aa8d7c8c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0803291321020.26338@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: apw@shadowen.org, davem@davemloft.net, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, jeremy@goop.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 29 Mar 2008 13:22:30 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 28 Mar 2008, Andrew Morton wrote:
> 
> > Why do we use gas at all here?  All we're doing is converting
> > 
> > ->NR_PAGEFLAGS 18 __NR_PAGEFLAGS         #
> > 
> > into
> > 
> > #define NR_PAGEFLAGS 18
> > 
> > which can be done with sed or whatever?
> 
> Only the compiler knows the value of __NR_PAGEFLAGS since it was defined 
> via enum. We are generating an object file and then extract the symbols.

I know.  I suggested that we process the .s file with sed, generating the
#defines for the .h file.  There is no need to assemble the .s file!

> This is the same process as used in arch/*/asm-offsets.*

Maybe that wasn't the best way of doing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

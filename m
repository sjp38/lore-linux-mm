Date: Mon, 14 Jan 2008 10:00:10 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/10] x86: Reduce memory and intra-node effects with
	large count NR_CPUs
Message-ID: <20080114090010.GA5404@elte.hu>
References: <20080113183453.973425000@sgi.com> <20080114081418.GB18296@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080114081418.GB18296@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Ingo Molnar <mingo@elte.hu> wrote:

> > 32cpus			  1kcpus-before		    1kcpus-after
> >    7172678 Total	   +23314404 Total	       -147590 Total
> 
> 1kcpus-after means it's +23314404-147590, i.e. +23166814? (i.e. a 0.6% 
> reduction of the bloat?)

or if it's relative to 32cpus then that's an excellent result :)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

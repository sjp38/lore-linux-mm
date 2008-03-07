Date: Fri, 7 Mar 2008 13:48:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Regression:  Re: [patch -mm 2/4] mempolicy: create mempolicy_operations
 structure
In-Reply-To: <1204922646.5340.73.camel@localhost>
Message-ID: <alpine.DEB.1.00.0803071341090.26765@chino.kir.corp.google.com>
References: <alpine.DEB.1.00.0803061135001.18590@chino.kir.corp.google.com>  <alpine.DEB.1.00.0803061135560.18590@chino.kir.corp.google.com> <1204922646.5340.73.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Lee Schermerhorn wrote:

> It also appears that the patch series listed above required a non-empty
> nodemask with MPOL_DEFAULT.  However, I didn't test that.  With this
> patch, MPOL_DEFAULT effectively ignores the nodemask--empty or not.
> This is a change in behavior that I have argued against, but the
> regression tests don't test this, so I'm not going to attempt to address
> it with this patch.
> 

Excuse me, but there was significant discussion about this on LKML and I 
eventually did force MPOL_DEFAULT to require a non-empty nodemask 
specifically because of your demand that it should.  It didn't originally 
require this in my patchset, and now you're removing the exact same 
requirement that you demanded.

You said on February 13:

	1) we've discussed the issue of returning EINVAL for non-empty
	nodemasks with MPOL_DEFAULT.  By removing this restriction, we run
	the risk of breaking applications if we should ever want to define
	a semantic to non-empty node mask for MPOL_DEFAULT.

If you want to remove this requirement now (please get agreement from 
Paul) and are sure of your position, you'll at least need an update to 
Documentation/vm/numa-memory-policy.txt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

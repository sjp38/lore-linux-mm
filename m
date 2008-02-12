Date: Tue, 12 Feb 2008 11:06:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to
 allowed nodes V3
In-Reply-To: <1202828903.4974.8.camel@localhost>
Message-ID: <alpine.DEB.1.00.0802121100211.9649@chino.kir.corp.google.com>
References: <alpine.LFD.1.00.0802092340400.2896@woody.linux-foundation.org>  <1202748459.5014.50.camel@localhost>  <20080212091910.29A0.KOSAKI.MOTOHIRO@jp.fujitsu.com>  <alpine.DEB.1.00.0802111649330.6119@chino.kir.corp.google.com>
 <1202828903.4974.8.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, Lee Schermerhorn wrote:

> Firstly, because this was the original API. 
> 
> Secondly, I consider this key to extensible API design.  Perhaps,
> someday, we might want to assign some semantic to certain non-empty
> nodemasks to MPOL_DEFAULT.  If we're allowing applications to pass
> arbitrary nodemask now, and just ignoring them, that becomes difficult.
> Just like dis-allowing unassigned flag values.
> 

I allow it with my patchset because there's simply no reason not to.

MPOL_DEFAULT is the default system-wide policy that does not require a 
nodemask as a parameter.  Both the man page (set_mempolicy(2)) and the 
documentation (Documentation/vm/numa_memory_policy.txt) state that.

It makes no sense in the future to assign a meaning to a nodemask passed 
along with MPOL_DEFAULT.  None at all.  The policy is simply the 
equivalent of default_policy and, as the system default, a nodemask 
parameter to the system default policy is wrong be definition.

So, logically, we can either allow all nodemasks to be passed with a 
MPOL_DEFAULT policy or none at all (it must be NULL).  Empty nodemasks 
don't have any logical relationship with MPOL_DEFAULT.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

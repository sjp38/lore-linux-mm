Date: Wed, 13 Feb 2008 10:32:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to
 allowed nodes V3
In-Reply-To: <1202920363.4978.69.camel@localhost>
Message-ID: <alpine.DEB.1.00.0802131030560.9186@chino.kir.corp.google.com>
References: <alpine.LFD.1.00.0802092340400.2896@woody.linux-foundation.org>  <1202748459.5014.50.camel@localhost>  <20080212091910.29A0.KOSAKI.MOTOHIRO@jp.fujitsu.com>  <alpine.DEB.1.00.0802111649330.6119@chino.kir.corp.google.com>  <1202828903.4974.8.camel@localhost>
  <alpine.DEB.1.00.0802121100211.9649@chino.kir.corp.google.com>  <1202861240.4974.25.camel@localhost>  <alpine.DEB.1.00.0802121632170.3291@chino.kir.corp.google.com> <1202920363.4978.69.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2008, Lee Schermerhorn wrote:

> I'm not sure why you don't want to require the nodemask to be NULL/empty
> in the case of MPOL_DEFAULT.  Perhaps it's from a code complexity
> viewpoint.  Or maybe you think we're being kind to the programmer by
> cutting them some slack.  Vis a vis the latter, I would argue that we're
> not doing a programmer any favor by letting this slide by.  MPOL_DEFAULT
> takes no nodemask.  So, if a non-empty nodemask is passed, the
> programmer has done something wrong. 
> 

I mentioned on LKML that I've currently folded all the current logic of 
mpol_check_policy() as it stands this minute in Linus' tree into 
mpol_new() so that non-empty nodemasks are no longer accepted for 
MPOL_DEFAULT.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 11 Feb 2008 19:17:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to
 allowed nodes V3
In-Reply-To: <20080212115952.29B2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.00.0802111912080.32542@chino.kir.corp.google.com>
References: <20080212103944.29A9.KOSAKI.MOTOHIRO@jp.fujitsu.com> <alpine.DEB.1.00.0802111757470.19213@chino.kir.corp.google.com> <20080212115952.29B2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, KOSAKI Motohiro wrote:

> Hmmmmmm
> sorry, I don't understand yet.
> 
> My test result was
> 
> RHEL5(initrd-2.6.18 + rhel patch)	EINVAL
> 2.6.24					EINVAL
> 2.6.24 + lee-patch			EINVAL
> 
> 
> I don't know current behavior good or wrong.
> but I think it is not regression.
> 

Yes, it's not a regression, but I'm asking why we can't allow this:

	nodemask_t nodes = NODE_MASK_NONE;

	node_set(1, &nodes);
	set_mempolicy(MPOL_DEFAULT, &nodes, MAX_NUMNODES);

It seems like that should not return -EINVAL and that it should just 
effect the system default of a MPOL_DEFAULT policy.

It's not a problem that I'm complaining about specifically in this patch, 
I'm just raising the concern that returning -EINVAL here is really 
unnecessary since mpol_new() will readily accept it.

So you can add my

	Acked-by: David Rientjes <rientjes@google.com>

to this patch, but I would like some counter-arguments presented that show 
why we shouldn't allow the above code to work later on.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

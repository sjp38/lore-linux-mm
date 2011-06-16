Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 346006B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 11:28:09 -0400 (EDT)
Subject: Re: [PATCH] slob: push the min alignment to long long
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <1308237823.15617.451.camel@calx>
References: <1308169466.15617.378.camel@calx>
	 <BANLkTi=QG3ywRhSx=npioJx-d=yyf=o29A@mail.gmail.com>
	 <1308171355.15617.401.camel@calx>
	 <20110615.181148.650483947691740732.davem@davemloft.net>
	 <1308178420.15617.447.camel@calx>
	 <BANLkTikOM6=fWnUA1bNZOM-jwg=o=CL8Ug@mail.gmail.com>
	 <1308237823.15617.451.camel@calx>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 16 Jun 2011 18:28:03 +0300
Message-ID: <1308238083.29073.20.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: David Miller <davem@davemloft.net>, sebastian@breakpoint.cc, cl@linux-foundation.org, linux-mm@kvack.org, netfilter@vger.kernel.org

On Thu, 2011-06-16 at 10:23 -0500, Matt Mackall wrote:
> > I don't agree. I think we should either provide defaults that work for
> > everyone and let architectures override them (which AFAICT Christoph's
> > patch does) or we flat out #error if architectures don't specify
> > alignment requirements.
> 
> Uh, isn't the latter precisely what I say above?
> 
> >  The current solution seems to be the worst one
> > from practical point of view.
> 
> Good, because no one's advocating for it.

Sorry, I totally misunderstood what you wrote!

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

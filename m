Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B47A38D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 03:23:30 -0500 (EST)
Date: Thu, 27 Jan 2011 09:23:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memsw: handle swapaccount kernel parameter correctly
Message-ID: <20110127082320.GA15500@tiehlicka.suse.cz>
References: <20110126152158.GA4144@tiehlicka.suse.cz>
 <20110126140618.8e09cd23.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110126140618.8e09cd23.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed 26-01-11 14:06:18, Andrew Morton wrote:
> On Wed, 26 Jan 2011 16:21:58 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > I am sorry but the patch which added swapaccount parameter is not
> > correct (we have discussed it https://lkml.org/lkml/2010/11/16/103).
> > I didn't get the way how __setup parameters are handled correctly.
> > The patch bellow fixes that.
> > 
> > I am CCing stable as well because the patch got into .37 kernel.
> > 
> > ---
> > >From 144c2e8aed27d82d48217896ee1f58dbaa7f1f84 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Wed, 26 Jan 2011 14:12:41 +0100
> > Subject: [PATCH] memsw: handle swapaccount kernel parameter correctly
> > 
> > __setup based kernel command line parameters handled in
> > obsolete_checksetup provides the parameter value including = (more
> > precisely everything right after the parameter name) so we have to check
> > for =0 resp. =1 here. If no value is given then we get an empty string
> > rather then NULL.
> 
> This doesn't provide a description of the bug which just got fixed.
> 
> From reading the code I think the current behaviour is
> 
> "swapaccount": works OK

Not really because the original test was !s || s="1" but as I am writing
in the commit message we are getting an empty string rather than NULL in
no parameter value case..
So noswapaccount is actually the only thing that is working.

> "noswapaccount": works OK
> "swapaccount=0": doesn't do anything
> "swapaccount=1": doesn't do anything
> 
> but I might be wrong about that.  Please send a changelog update to
> clarify all this.

Sorry for not being specific enough. What about somthing like this:
---

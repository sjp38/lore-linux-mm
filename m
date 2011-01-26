Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B85048D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 17:09:14 -0500 (EST)
Date: Wed, 26 Jan 2011 14:06:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memsw: handle swapaccount kernel parameter correctly
Message-Id: <20110126140618.8e09cd23.akpm@linux-foundation.org>
In-Reply-To: <20110126152158.GA4144@tiehlicka.suse.cz>
References: <20110126152158.GA4144@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jan 2011 16:21:58 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> I am sorry but the patch which added swapaccount parameter is not
> correct (we have discussed it https://lkml.org/lkml/2010/11/16/103).
> I didn't get the way how __setup parameters are handled correctly.
> The patch bellow fixes that.
> 
> I am CCing stable as well because the patch got into .37 kernel.
> 
> ---
> >From 144c2e8aed27d82d48217896ee1f58dbaa7f1f84 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 26 Jan 2011 14:12:41 +0100
> Subject: [PATCH] memsw: handle swapaccount kernel parameter correctly
> 
> __setup based kernel command line parameters handled in
> obsolete_checksetup provides the parameter value including = (more
> precisely everything right after the parameter name) so we have to check
> for =0 resp. =1 here. If no value is given then we get an empty string
> rather then NULL.

This doesn't provide a description of the bug which just got fixed.

>From reading the code I think the current behaviour is

"swapaccount": works OK
"noswapaccount": works OK
"swapaccount=0": doesn't do anything
"swapaccount=1": doesn't do anything

but I might be wrong about that.  Please send a changelog update to
clarify all this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

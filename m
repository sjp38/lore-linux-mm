Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C38649000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 10:18:36 -0400 (EDT)
Date: Thu, 29 Sep 2011 09:18:33 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slub: remove a minus instruction in get_partial_node
In-Reply-To: <1317290716.4188.1227.camel@debian>
Message-ID: <alpine.DEB.2.00.1109290917300.9382@router.home>
References: <1317290716.4188.1227.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

On Thu, 29 Sep 2011, Alex,Shi wrote:

> Don't do a minus action in get_partial_node function here, since
> it is always zero.

A slab on the partial lists always has objects available. Why would it be
zero?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

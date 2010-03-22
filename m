Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 974576B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 10:44:12 -0400 (EDT)
Date: Mon, 22 Mar 2010 09:43:53 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/6] Mempolicy: rename policy_types and cleanup
 initialization
In-Reply-To: <20100319185952.21430.8872.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1003220942430.15360@router.home>
References: <20100319185933.21430.72039.sendpatchset@localhost.localdomain> <20100319185952.21430.8872.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 19 Mar 2010, Lee Schermerhorn wrote:

> Rename 'policy_types[]' to 'policy_modes[]' to better match the
> array contents.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

Small nitpick: MPOL_MAX should be called MPOL_NR to follow vmstat.h and
mmzones.h's way of naming the n+1st element.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5649F6B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 10:40:49 -0400 (EDT)
Date: Mon, 22 Mar 2010 09:40:36 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/6] Mempolicy: Don't call mpol_set_nodemask() when
 no_context
In-Reply-To: <20100319185940.21430.38739.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1003220939410.15360@router.home>
References: <20100319185933.21430.72039.sendpatchset@localhost.localdomain> <20100319185940.21430.38739.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Just use i instead of mode? Local variables typically have short names.
"mode" sounds like a parameter. But its just style so ignore my comments
if you want.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

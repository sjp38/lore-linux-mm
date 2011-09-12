Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 407FA900137
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 11:24:40 -0400 (EDT)
Date: Mon, 12 Sep 2011 10:24:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] slub: remove obsolete code path in __slab_free()
 for per cpu partial
In-Reply-To: <1315559166.31737.793.camel@debian>
Message-ID: <alpine.DEB.2.00.1109121024070.15509@router.home>
References: <1315558961.31737.790.camel@debian> <1315559166.31737.793.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

On Fri, 9 Sep 2011, Alex,Shi wrote:

> On Fri, 2011-09-09 at 17:02 +0800, Alex,Shi wrote:
> > If there are still some objects left in slab, the slab page will be put
> > to per cpu partial list. So remove the obsolete code path.

Did you run this with debugging on? I think the code is needed then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

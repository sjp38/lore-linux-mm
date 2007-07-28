Date: Sat, 28 Jul 2007 15:19:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from
 MPOL_INTERLEAVE masks
Message-Id: <20070728151912.c541aec0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1185566878.5069.123.camel@localhost>
References: <1185566878.5069.123.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <clameter@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>, kxr@sgi.com, ak@suse.de, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007 16:07:57 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> Questions:
> 
> * do we need/want a sysctl for run time modifications?  IMO, no.
> 

I can agree that runtime modification is not necessary. But applications or
libnuma will not use this information ? Doing all in implicit way is enough ?
(maybe enough)

BTW, could you print "nodes of XXXX are ignored in INTERLEAVE mempolicy" to
/var/log/messages at boot ?
 
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

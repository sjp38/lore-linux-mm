From: Andi Kleen <ak@suse.de>
Subject: Re: tmpfs and numa mempolicy
Date: Mon, 4 Jun 2007 15:43:23 +0200
References: <20070603203003.64fd91a8.randy.dunlap@oracle.com> <Pine.LNX.4.64.0706041307560.12071@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0706041307560.12071@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200706041543.24516.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

> I've appended a patch to check node_online_map below, and update
> tmpfs.txt accordingly.

Looks good to me.

> But it looks to me like mempolicy.c normally never lets a nonline
> node get into any of its policies, and it would be a bit tedious,
> error-prone and unnecessary overhead to relax that: so tmpfs mount
> is at present a dangerous exception in this regard.
>
> Would you be happy with this change, Robin?  I'm not very NUMArate:
> do nodes in fact ever get onlined after early system startup?

Currently not, but at some point they might be. But then there will
be quite a lot of code to fix for that anyways so don't let it stop
you here.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

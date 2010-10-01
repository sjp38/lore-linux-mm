Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 396D46B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 14:45:40 -0400 (EDT)
Date: Fri, 1 Oct 2010 13:45:38 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 2/9] v3 Add mutex for adding/removing memory blocks
Message-ID: <20101001184538.GI14064@sgi.com>
References: <4CA62700.7010809@austin.ibm.com>
 <4CA62896.2060307@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CA62896.2060307@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 01, 2010 at 01:29:42PM -0500, Nathan Fontenot wrote:
> Add a new mutex for use in adding and removing of memory blocks.  This
> is needed to avoid any race conditions in which the same memory block could
> be added and removed at the same time.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

Reviewed-by: Robin Holt <holt@sgi.com>

I am fine with this patch by itself, but its only real function is
to protect the count introduced by the next patch.  You might want to
combine the patches, but if not, that is fine as well.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

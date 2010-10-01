Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3B7FD6B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 14:55:42 -0400 (EDT)
Date: Fri, 1 Oct 2010 13:55:39 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 6/9] v3 Update node sysfs code
Message-ID: <20101001185539.GM14064@sgi.com>
References: <4CA62700.7010809@austin.ibm.com>
 <4CA629BA.60100@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CA629BA.60100@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 01, 2010 at 01:34:34PM -0500, Nathan Fontenot wrote:
> Update the node sysfs code to be aware of the new capability for a memory
> block to contain multiple memory sections and be aware of the memory block
> structure name changes (start_section_nr).  This requires an additional
> parameter to unregister_mem_sect_under_nodes so that we know which memory
> section of the memory block to unregister.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

Reviewed-by: Robin Holt <holt@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

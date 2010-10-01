Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7B1096B0078
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 14:54:07 -0400 (EDT)
Date: Fri, 1 Oct 2010 13:54:04 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 5/9] v3 rename phys_index properties of memory block
 struct
Message-ID: <20101001185404.GL14064@sgi.com>
References: <4CA62700.7010809@austin.ibm.com>
 <4CA62982.5080900@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CA62982.5080900@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 01, 2010 at 01:33:38PM -0500, Nathan Fontenot wrote:
> Update the 'phys_index' property of a the memory_block struct to be
> called start_section_nr, and add a end_section_nr property.  The
> data tracked here is the same but the updated naming is more in line
> with what is stored here, namely the first and last section number
> that the memory block spans.
> 
> The names presented to userspace remain the same, phys_index for
> start_section_nr and end_phys_index for end_section_nr, to avoid breaking
> anything in userspace.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

Reviewed-by: Robin Holt <holt@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

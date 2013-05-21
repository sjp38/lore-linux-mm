Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id C92DE6B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 12:33:13 -0400 (EDT)
Date: Tue, 21 May 2013 09:33:12 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] drivers/base: Use attribute groups to create sysfs
 memory files
Message-ID: <20130521163312.GA27705@kroah.com>
References: <518A78CC.2000501@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <518A78CC.2000501@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 08, 2013 at 11:09:48AM -0500, Nathan Fontenot wrote:
> Update the sysfs memory code to create/delete files at the time of device
> and subsystem registration.
> 
> The current code creates files in the root memory directory explicitly through
> the use of init_* routines. The files for each memory block are created and
> deleted explicitly using the mem_[create|delete]_simple_file macros.
> 
> This patch creates attribute groups for the memory root files and files in
> each memory block directory so that they are created and deleted implicitly
> at subsys and device register and unregister time.
>  
> This did necessitate moving the register_memory() and unregister_memory()
> routines in the file. There are no changes to unregister_memory, the
> register_memory routine is only updated to set the dev.groups field.
> 
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
> 
> Please cc me on responses/comments.
> ---
>  drivers/base/memory.c |  163 ++++++++++++++++++++++----------------------------
>  1 file changed, 72 insertions(+), 91 deletions(-)

This doesn't seem to apply to 3.10-rc2, can you refresh it and resend it
so that I can apply it?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

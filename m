Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D494C6B012A
	for <linux-mm@kvack.org>; Wed, 29 May 2013 17:27:56 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 29 May 2013 15:27:55 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id E39183E40052
	for <linux-mm@kvack.org>; Wed, 29 May 2013 15:27:34 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4TLRg0w068112
	for <linux-mm@kvack.org>; Wed, 29 May 2013 15:27:45 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4TLRgRu025759
	for <linux-mm@kvack.org>; Wed, 29 May 2013 15:27:42 -0600
Message-ID: <51A672CC.9020403@linux.vnet.ibm.com>
Date: Wed, 29 May 2013 14:27:40 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH updated] drivers/base: Use attribute groups to create
 sysfs memory files
References: <51A58F4D.3020804@linux.vnet.ibm.com>
In-Reply-To: <51A58F4D.3020804@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/28/2013 10:17 PM, Nathan Fontenot wrote:
> Update the sysfs memory code to create/delete files at the time of device
> and subsystem registration.
>
> The current code creates files in the root memory directory explicitly
> through
> the use of init_* routines. The files for each memory block are created and
> deleted explicitly using the mem_[create|delete]_simple_file macros.
>
> This patch creates attribute groups for the memory root files and files in
> each memory block directory so that they are created and deleted implicitly
> at subsys and device register and unregister time.
>
> This did necessitate moving the register_memory() routine and update
> it to set the dev.groups field.
>
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
>
> Updated to apply cleanly to rc2.
>
> Please cc me on responses/comments.
> ---
>   drivers/base/memory.c |  143
> +++++++++++++++++++++-----------------------------
>   1 file changed, 62 insertions(+), 81 deletions(-)
>
> Index: linux/drivers/base/memory.c
> ===================================================================
> --- linux.orig/drivers/base/memory.c    2013-05-28 22:53:58.000000000 -0500
> +++ linux/drivers/base/memory.c 2013-05-28 22:56:49.000000000 -0500

These changes look good, but this email doesn't play nice with `git am`. ex:

	"fatal: corrupt patch at line 80"

There is nothing particularly bad about line 80. Please fix and resend 
(git format-patch generally gets this right, maybe use that?)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

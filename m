Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id AEEEF6B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 17:45:59 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 31 May 2013 15:45:58 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 732873E4006C
	for <linux-mm@kvack.org>; Fri, 31 May 2013 15:45:38 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4VLjsjE147878
	for <linux-mm@kvack.org>; Fri, 31 May 2013 15:45:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4VLjsj5023039
	for <linux-mm@kvack.org>; Fri, 31 May 2013 15:45:54 -0600
Message-ID: <51A91A0F.4020408@linux.vnet.ibm.com>
Date: Fri, 31 May 2013 14:45:51 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2]  drivers/base: Use attribute groups to create sysfs
 memory files
References: <51A908A3.7010006@linux.vnet.ibm.com>
In-Reply-To: <51A908A3.7010006@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On 05/31/2013 01:31 PM, Nathan Fontenot wrote:
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
> This did necessitate moving the register_memory() updating it to set the
> dev.groups field.
>
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
>
> Please cc me on responses/comments.
>
> v2: refreshed the patch, previous version was corrupted. There is no difference
> otherwise between this patch and the previous one sent out.

Still looks broken. Tabs have been converted into spaces, and the top of 
the patch is whitespace padded to 80 characters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

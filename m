Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 0A9AD6B0044
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 15:27:00 -0400 (EDT)
Message-ID: <500DA581.1020602@sgi.com>
Date: Mon, 23 Jul 2012 14:26:57 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 v5][resend] tmpfs: interleave the starting node of
 /dev/shmem
References: <1341845199-25677-1-git-send-email-nzimmer@sgi.com> <1341845199-25677-2-git-send-email-nzimmer@sgi.com> <1341845199-25677-3-git-send-email-nzimmer@sgi.com> <20120723105819.GA4455@mwanda>
In-Reply-To: <20120723105819.GA4455@mwanda>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Hugh Dickins <hughd@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

Yes I had failed to notice that.
I'll send a fix shortly.


On 07/23/2012 05:58 AM, Dan Carpenter wrote:
> On Mon, Jul 09, 2012 at 09:46:39AM -0500, Nathan Zimmer wrote:
>> +static unsigned long shmem_interleave(struct vm_area_struct *vma,
>> +					unsigned long addr)
>> +{
>> +	unsigned long offset;
>> +
>> +	/* Use the vm_files prefered node as the initial offset. */
>> +	offset = (unsigned long *) vma->vm_private_data;
> Should this be?:
> 	offset = (unsigned long)vma->vm_private_data;
>
> offset is an unsigned long, not a pointer.  ->vm_private_data is a
> void pointer.
>
> It causes a GCC warning:
> mm/shmem.c: In function a??shmem_interleavea??:
> mm/shmem.c:1341:9: warning: assignment makes integer from pointer without a cast [enabled by default]
>
>> +
>> +	offset += ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
>> +
>> +	return offset;
>> +}
>>   #endif
> regards,
> dan carpenter
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

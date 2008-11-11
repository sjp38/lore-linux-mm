Message-ID: <4919D83C.20807@redhat.com>
Date: Tue, 11 Nov 2008 21:08:44 +0200
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <20081111103051.979aea57.akpm@linux-foundation.org> <4919D370.7080301@redhat.com>
In-Reply-To: <4919D370.7080301@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Andrew Morton wrote:
>> The whole approach seems wrong to me.  The kernel lost track of these
>> pages and then we run around post-facto trying to fix that up again. 
>> Please explain (for the changelog) why the kernel cannot get this right
>> via the usual sharing, refcounting and COWing approaches.
>>   
>
> For kvm, the kernel never knew those pages were shared.  They are 
> loaded from independent (possibly compressed and encrypted) disk 
> images.  These images are different; but some pages happen to be the 
> same because they came from the same installation media.

As Avi said, in kvm we cannot know how the guest is going to map its 
pages, we have nothing to do but to scan for the identical pages
(you can have pages that are shared that are in whole different offset 
inside the guest)

>
> For OpenVZ the situation is less clear, but if you allow users to 
> independently upgrade their chroots you will eventually arrive at the 
> same scenario (unless of course you apply the same merging strategy at 
> the filesystem level).
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

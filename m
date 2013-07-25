Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 296C96B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 06:44:54 -0400 (EDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 25 Jul 2013 11:36:23 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9EFC92190066
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 11:48:59 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6PAicZR44892320
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 10:44:38 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6PAimud022821
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:44:49 -0600
Message-ID: <51F101A0.3050104@de.ibm.com>
Date: Thu, 25 Jul 2013 12:44:48 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/2] s390/kvm: add kvm support for guest page hinting
 v2
References: <1374742461-29160-1-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1374742461-29160-1-git-send-email-schwidefsky@de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On 25/07/13 10:54, Martin Schwidefsky wrote:
> v1->v2:
>  - found a way to simplify the common code patch
> 
> Linux on s390 as a guest under z/VM has been using the guest page
> hinting interface (alias collaborative memory management) for a long
> time. The full version with volatile states has been deemed to be too
> complicated (see the old discussion about guest page hinting e.g. on
> http://marc.info/?l=linux-mm&m=123816662017742&w=2).
> What is currently implemented for the guest is the unused and stable
> states to mark unallocated pages as freely available to the host.
> This works just fine with z/VM as the host.
> 
> The two patches in this series implement the guest page hinting
> interface for the unused and stable states in the KVM host.
> Most of the code specific to s390 but there is a common memory
> management part as well, see patch #1.
> 
> The code is working stable now, from my point of view this is ready
> for prime-time.
> 
> Konstantin Weitz (2):
>   mm: add support for discard of unused ptes
>   s390/kvm: support collaborative memory management

Can you also add the patch from our tree that reset the usage states
on reboot (diag 308 subcode 3 and 4)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

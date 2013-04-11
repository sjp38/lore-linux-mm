Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id F039E6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 01:12:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 10:38:10 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 05A6C1258023
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 10:43:26 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B5BuKW60620898
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 10:41:56 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B5BwY6000680
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 05:11:59 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 12/25] powerpc: Return all the valid pte ecndoing in KVM_PPC_GET_SMMU_INFO ioctl
In-Reply-To: <20130411032447.GU8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1365055083-31956-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130411032447.GU8165@truffula.fritz.box>
Date: Thu, 11 Apr 2013 10:41:57 +0530
Message-ID: <874nfdodlu.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

David Gibson <dwg@au1.ibm.com> writes:

> On Thu, Apr 04, 2013 at 11:27:50AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
> Surely this can't be correct until the KVM H_ENTER implementation is
> updated to cope with the MPSS page sizes.

Why ? We are returning info regarding penc values for different
combination. I would guess qemu to only use info related to base page
size. Rest it can ignore right ?. Obviously i haven't tested this
part. So let me know if I should drop this ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

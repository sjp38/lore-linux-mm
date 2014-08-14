Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6C60A6B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 13:21:15 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so1975185pab.6
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 10:21:15 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id qh9si4852170pdb.17.2014.08.14.10.21.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Aug 2014 10:21:14 -0700 (PDT)
Message-ID: <53ECEFF5.1040800@zytor.com>
Date: Thu, 14 Aug 2014 10:20:53 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] x86: add phys addr validity check for /dev/mem mmap
References: <1408025927-16826-1-git-send-email-fhrbata@redhat.com> <1408025927-16826-2-git-send-email-fhrbata@redhat.com> <53ECE573.1030405@intel.com>
In-Reply-To: <53ECE573.1030405@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Frantisek Hrbata <fhrbata@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com

On 08/14/2014 09:36 AM, Dave Hansen wrote:
> Thanks for dredging this back up!
> 
> On 08/14/2014 07:18 AM, Frantisek Hrbata wrote:
>> +int valid_phys_addr_range(phys_addr_t addr, size_t count)
>> +{
>> +	return addr + count <= __pa(high_memory);
>> +}
> 
> Is this correct on 32-bit?  It would limit /dev/mem to memory below 896MB.
> 

Last I checked, /dev/mem was already broken for highmem... which is
actually a problem.  I would prefer to see it fixed.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

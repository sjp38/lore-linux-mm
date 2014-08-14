Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7C02F6B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 13:54:14 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id v10so1235812qac.19
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 10:54:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 61si8268325qgr.27.2014.08.14.10.54.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Aug 2014 10:54:04 -0700 (PDT)
Date: Thu, 14 Aug 2014 19:53:46 +0200
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: Re: [PATCH 1/1] x86: add phys addr validity check for /dev/mem mmap
Message-ID: <20140814175346.GB7575@localhost.localdomain>
Reply-To: Frantisek Hrbata <fhrbata@redhat.com>
References: <1408025927-16826-1-git-send-email-fhrbata@redhat.com>
 <1408025927-16826-2-git-send-email-fhrbata@redhat.com>
 <53ECE573.1030405@intel.com>
 <53ECEFF5.1040800@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53ECEFF5.1040800@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com

On Thu, Aug 14, 2014 at 10:20:53AM -0700, H. Peter Anvin wrote:
> On 08/14/2014 09:36 AM, Dave Hansen wrote:
> > Thanks for dredging this back up!
> > 
> > On 08/14/2014 07:18 AM, Frantisek Hrbata wrote:
> >> +int valid_phys_addr_range(phys_addr_t addr, size_t count)
> >> +{
> >> +	return addr + count <= __pa(high_memory);
> >> +}
> > 
> > Is this correct on 32-bit?  It would limit /dev/mem to memory below 896MB.
> > 
> 
> Last I checked, /dev/mem was already broken for highmem... which is
> actually a problem.  I would prefer to see it fixed.
> 
> 	-hpa
> 

Hi Peter,

thank you for jumping in again. I'm not going to pretent I fully understand this
code, as proven by Dave :), but wouldn't it help just to move the high_memory
check directly to the xlate_dev_mem_ptr. Meaning no high_memory check in
valid_phys_addr_range for x86. I sent more info in my reply to Dave's mail.

Again many thanks.


-- 
Frantisek Hrbata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

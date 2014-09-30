Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id ADCC46B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 12:34:09 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id a13so349814igq.11
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 09:34:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z13si17169067igg.1.2014.09.30.09.34.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Sep 2014 09:34:08 -0700 (PDT)
Date: Tue, 30 Sep 2014 18:33:53 +0200
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: Re: [RESEND PATCH 2/4] x86: add phys addr validity check for
 /dev/mem mmap
Message-ID: <20140930163353.GC3073@localhost.localdomain>
Reply-To: Frantisek Hrbata <fhrbata@redhat.com>
References: <1411990382-11902-1-git-send-email-fhrbata@redhat.com>
 <1411990382-11902-3-git-send-email-fhrbata@redhat.com>
 <alpine.DEB.2.02.1409292211560.22082@ionos.tec.linutronix.de>
 <20140930124121.GB3073@localhost.localdomain>
 <542ABDE7.7090808@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <542ABDE7.7090808@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com, torvalds@linux-foundation.org

On Tue, Sep 30, 2014 at 07:27:51AM -0700, Dave Hansen wrote:
> On 09/30/2014 05:41 AM, Frantisek Hrbata wrote:
> > Does it make sense to replace "count" with "size" so it's consistent with the
> > rest or do you prefer "nr_bytes" or as Dave proposed "len_bytes"?
> 
> I don't care what it is as long as it has a unit in it.

Hi Dave/Thomas,

I sent v2 of this patch set, which uses the "len_bytes". Again, I'm sorry I
forgot to fix this the first time.

Many thanks

-- 
Frantisek Hrbata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

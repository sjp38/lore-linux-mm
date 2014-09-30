Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 05B546B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 17:57:53 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id k14so6086565wgh.17
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 14:57:53 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id de9si22339961wjb.109.2014.09.30.14.57.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 30 Sep 2014 14:57:52 -0700 (PDT)
Date: Tue, 30 Sep 2014 23:57:46 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RESEND PATCH 2/4] x86: add phys addr validity check for /dev/mem
 mmap
In-Reply-To: <20140930163353.GC3073@localhost.localdomain>
Message-ID: <alpine.DEB.2.11.1409302357290.4455@nanos>
References: <1411990382-11902-1-git-send-email-fhrbata@redhat.com> <1411990382-11902-3-git-send-email-fhrbata@redhat.com> <alpine.DEB.2.02.1409292211560.22082@ionos.tec.linutronix.de> <20140930124121.GB3073@localhost.localdomain> <542ABDE7.7090808@intel.com>
 <20140930163353.GC3073@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com, torvalds@linux-foundation.org

On Tue, 30 Sep 2014, Frantisek Hrbata wrote:
> On Tue, Sep 30, 2014 at 07:27:51AM -0700, Dave Hansen wrote:
> > On 09/30/2014 05:41 AM, Frantisek Hrbata wrote:
> > > Does it make sense to replace "count" with "size" so it's consistent with the
> > > rest or do you prefer "nr_bytes" or as Dave proposed "len_bytes"?
> > 
> > I don't care what it is as long as it has a unit in it.
> 
> Hi Dave/Thomas,
> 
> I sent v2 of this patch set, which uses the "len_bytes". Again, I'm sorry I
> forgot to fix this the first time.

No problem. Shit happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

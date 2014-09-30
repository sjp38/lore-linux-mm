Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 630116B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 10:27:55 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id eu11so1905913pac.7
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 07:27:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sr5si26979962pbc.182.2014.09.30.07.27.53
        for <linux-mm@kvack.org>;
        Tue, 30 Sep 2014 07:27:54 -0700 (PDT)
Message-ID: <542ABDE7.7090808@intel.com>
Date: Tue, 30 Sep 2014 07:27:51 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH 2/4] x86: add phys addr validity check for /dev/mem
 mmap
References: <1411990382-11902-1-git-send-email-fhrbata@redhat.com> <1411990382-11902-3-git-send-email-fhrbata@redhat.com> <alpine.DEB.2.02.1409292211560.22082@ionos.tec.linutronix.de> <20140930124121.GB3073@localhost.localdomain>
In-Reply-To: <20140930124121.GB3073@localhost.localdomain>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com, torvalds@linux-foundation.org

On 09/30/2014 05:41 AM, Frantisek Hrbata wrote:
> Does it make sense to replace "count" with "size" so it's consistent with the
> rest or do you prefer "nr_bytes" or as Dave proposed "len_bytes"?

I don't care what it is as long as it has a unit in it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

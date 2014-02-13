Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 01E946B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 18:06:42 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so11388395pab.16
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 15:06:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sj5si3510133pab.197.2014.02.13.15.06.41
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 15:06:42 -0800 (PST)
Date: Thu, 13 Feb 2014 15:06:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 0/3]  powerpc: Fix random application crashes with
 NUMA_BALANCING enabled
Message-Id: <20140213150639.2b9124797ac4975b6119f6f0@linux-foundation.org>
In-Reply-To: <1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Wed, 12 Feb 2014 09:13:35 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Hello,
> 
> This patch series fix random application crashes observed on ppc64 with numa
> balancing enabled. Without the patch we see crashes like
> 
> anacron[14551]: unhandled signal 11 at 0000000000000041 nip 000000003cfd54b4 lr 000000003cfd5464 code 30001
> anacron[14599]: unhandled signal 11 at 0000000000000041 nip 000000003efc54b4 lr 000000003efc5464 code 30001
> 

Random application crashes are bad.  Which kernel version(s) do you think
need fixing here?

I grabbed the patches but would like to hear from Ben (or something
approximating him) before doing anything with them, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

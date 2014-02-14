Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 83D4B6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 00:42:02 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id x13so19132597qcv.19
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 21:42:02 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id mm10si1325556qcb.97.2014.02.13.21.42.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 21:42:00 -0800 (PST)
Message-ID: <1392356501.3835.217.camel@pasglop>
Subject: Re: [PATCH V2 0/3]  powerpc: Fix random application crashes with
 NUMA_BALANCING enabled
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 14 Feb 2014 16:41:41 +1100
In-Reply-To: <20140213150639.2b9124797ac4975b6119f6f0@linux-foundation.org>
References: 
	<1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20140213150639.2b9124797ac4975b6119f6f0@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, riel@redhat.com, mgorman@suse.de, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 2014-02-13 at 15:06 -0800, Andrew Morton wrote:
> On Wed, 12 Feb 2014 09:13:35 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > Hello,
> > 
> > This patch series fix random application crashes observed on ppc64 with numa
> > balancing enabled. Without the patch we see crashes like
> > 
> > anacron[14551]: unhandled signal 11 at 0000000000000041 nip 000000003cfd54b4 lr 000000003cfd5464 code 30001
> > anacron[14599]: unhandled signal 11 at 0000000000000041 nip 000000003efc54b4 lr 000000003efc5464 code 30001
> > 
> 
> Random application crashes are bad.  Which kernel version(s) do you think
> need fixing here?
> 
> I grabbed the patches but would like to hear from Ben (or something
> approximating him) before doing anything with them, please.

Ah good. Did you grab v2 ? v1 had a compile breakage. I was about to
send them to Linus today as well but then got distracted by a sick
child, so I'm happy for you to pick them up and send them to the
boss :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

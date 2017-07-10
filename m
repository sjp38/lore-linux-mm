Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5550C44084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:15:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p64so25898753wrc.8
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 10:15:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 30si8526645wrd.171.2017.07.10.10.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 10:15:55 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6AHE0OC022496
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:15:54 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bmb2ef8mu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:15:53 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 10 Jul 2017 11:15:53 -0600
Date: Mon, 10 Jul 2017 10:15:36 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 00/38] powerpc: Memory Protection Keys
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <d9030b2c-493b-94c4-8c97-8aaec3be34ba@linux.vnet.ibm.com>
 <20170710060544.GF5713@ram.oc3035372033.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170710060544.GF5713@ram.oc3035372033.ibm.com>
Message-Id: <20170710171536.GA5716@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Sun, Jul 09, 2017 at 11:05:44PM -0700, Ram Pai wrote:
> On Mon, Jul 10, 2017 at 11:13:23AM +0530, Anshuman Khandual wrote:
> > On 07/06/2017 02:51 AM, Ram Pai wrote:
.....
> 
> > do you have data points to show the difference in
> > performance between this version and the last one where
> > we skipped the bits from PTE and directly programmed the
> > HPTE entries looking into VMA bits.
> 
> No. I dont. I am hoping you can help me out with this.
Anshuman,
	The last version where we skipped the PTE bits is guaranteed
	to be bad/horrible. For one it has a bug, since it accesses
	the vma without a lock. And even if we did take a lock, it
	will slow down the page-hash path un-acceptably. So there is
	no point measuring the performance of that design.

	I think the number we want to measure is -- the performance 
	with the current design and comparing that to the performance
	without memkey feature. We want to find if there is
	any degradation by adding this feature.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

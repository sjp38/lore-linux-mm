Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64E356B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 00:11:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y134so79266787pfg.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 21:11:09 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id 123si4010145pfu.156.2016.07.13.21.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 21:11:08 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id ks6so24262185pab.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 21:11:08 -0700 (PDT)
Date: Thu, 14 Jul 2016 14:10:58 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [v2][PATCH] KVM: PPC: Book3S HV: Migrate pinned pages out of CMA
Message-ID: <20160714041058.GF18277@balbir.ozlabs.ibm.com>
Reply-To: bsingharora@gmail.com
References: <57d99598-2350-9578-5f93-b551cda12d23@ozlabs.au.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57d99598-2350-9578-5f93-b551cda12d23@ozlabs.au.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

On Thu, Jul 14, 2016 at 01:11:03PM +1000, Balbir Singh wrote:
> 
>

The from address is bad, resending with the right email address 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

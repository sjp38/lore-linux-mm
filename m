Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A858440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:37:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e199so66324939pfh.7
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:37:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z6si4784630pgb.140.2017.07.13.13.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 13:37:21 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6DKYXsr037440
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:37:21 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bpcn97xs4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:37:20 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 13 Jul 2017 14:37:20 -0600
Date: Thu, 13 Jul 2017 13:37:04 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 14/38] powerpc: initial plumbing for key management
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-15-git-send-email-linuxram@us.ibm.com>
 <20170712132825.2a37e2e9@firefly.ozlabs.ibm.com>
 <20170713074500.GF5525@ram.oc3035372033.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170713074500.GF5525@ram.oc3035372033.ibm.com>
Message-Id: <20170713203704.GA5538@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Thu, Jul 13, 2017 at 12:45:00AM -0700, Ram Pai wrote:
> On Wed, Jul 12, 2017 at 01:28:25PM +1000, Balbir Singh wrote:
> > On Wed,  5 Jul 2017 14:21:51 -0700
> > Ram Pai <linuxram@us.ibm.com> wrote:
> > 
> > > Initial plumbing to manage all the keys supported by the
> > > hardware.
> > > 
> > > Total 32 keys are supported on powerpc. However pkey 0,1
> > > and 31 are reserved. So effectively we have 29 pkeys.
> > > 
> > > This patch keeps track of reserved keys, allocated  keys
> > > and keys that are currently free.
> > 
> > It looks like this patch will only work in guest mode?
> > Is that an assumption we've made? What happens if I use
> > keys when running in hypervisor mode?
> 
> It works in supervisor mode, as a guest aswell as a bare-metal
> kernel. Whatever needs to be done in hypervisor mode
> is already there in power-kvm.

I realize i did not answer your question accurately...
"What happens if I use keys when running in hypervisor mode?"

Its not clear what happens. As far as I can tell the MMU does
not check key violation when in hypervisor mode. So effectively
I think, keys are ineffective when in hypervisor mode.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

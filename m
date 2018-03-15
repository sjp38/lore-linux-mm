Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9444E6B000A
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:21:53 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l32so4913148qtd.2
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:21:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s33si3702075qtj.278.2018.03.15.10.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 10:21:48 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2FHK4YF082192
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:21:47 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gqv6f2yh3-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:21:46 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 15 Mar 2018 17:21:44 -0000
Date: Thu, 15 Mar 2018 10:21:29 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v3] x86: treat pkey-0 special
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1521061214-22385-1-git-send-email-linuxram@us.ibm.com>
 <alpine.DEB.2.21.1803151039430.1525@nanos.tec.linutronix.de>
 <f5ef79ef-122a-e0a3-9b8e-d49c33f4a417@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f5ef79ef-122a-e0a3-9b8e-d49c33f4a417@intel.com>
Message-Id: <20180315172129.GD1060@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On Thu, Mar 15, 2018 at 08:55:31AM -0700, Dave Hansen wrote:
> On 03/15/2018 02:46 AM, Thomas Gleixner wrote:
> >> +	if (!pkey || !mm_pkey_is_allocated(mm, pkey))
> > Why this extra check? mm_pkey_is_allocated(mm, 0) should not return true
> > ever. If it does, then this wants to be fixed.
> 
> I was thinking that we _do_ actually want it to seem allocated.  It just
> get "allocated" implicitly when an mm is created.  I think that will
> simplify the code if we avoid treating it specially in as many places as
> possible.

I think, the logic that makes pkey-0 special must to go
in arch-neutral code.   How about checking for pkey-0 in sys_pkey_free()
itself?

RP

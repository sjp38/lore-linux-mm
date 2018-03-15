Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 800426B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 11:55:40 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z11-v6so3424801plo.21
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 08:55:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i2si3663448pgf.145.2018.03.15.08.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 08:55:39 -0700 (PDT)
Subject: Re: [PATCH v3] x86: treat pkey-0 special
References: <1521061214-22385-1-git-send-email-linuxram@us.ibm.com>
 <alpine.DEB.2.21.1803151039430.1525@nanos.tec.linutronix.de>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f5ef79ef-122a-e0a3-9b8e-d49c33f4a417@intel.com>
Date: Thu, 15 Mar 2018 08:55:31 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1803151039430.1525@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ram Pai <linuxram@us.ibm.com>
Cc: mingo@redhat.com, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On 03/15/2018 02:46 AM, Thomas Gleixner wrote:
>> +	if (!pkey || !mm_pkey_is_allocated(mm, pkey))
> Why this extra check? mm_pkey_is_allocated(mm, 0) should not return true
> ever. If it does, then this wants to be fixed.

I was thinking that we _do_ actually want it to seem allocated.  It just
get "allocated" implicitly when an mm is created.  I think that will
simplify the code if we avoid treating it specially in as many places as
possible.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8B7440856
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 03:39:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x23so3514204wrb.6
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 00:39:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si1593489wmv.29.2017.07.12.00.39.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 00:39:49 -0700 (PDT)
Date: Wed, 12 Jul 2017 09:39:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v5 00/38] powerpc: Memory Protection Keys
Message-ID: <20170712073945.GC28912@dhcp22.suse.cz>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <20170711145246.GA11917@dhcp22.suse.cz>
 <20170711193257.GB5525@ram.oc3035372033.ibm.com>
 <20170712072337.GB28912@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170712072337.GB28912@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Wed 12-07-17 09:23:37, Michal Hocko wrote:
> On Tue 11-07-17 12:32:57, Ram Pai wrote:
[...]
> > Ideally the MMU looks at the PTE for keys, in order to enforce
> > protection. This is the case with x86 and is the case with power9 Radix
> > page table. Hence the keys have to be programmed into the PTE.
> 
> But x86 doesn't update ptes for PKEYs, that would be just too expensive.
> You could use standard mprotect to do the same...

OK, this seems to be a misunderstanding and confusion on my end.
do_mprotect_pkey does mprotect_fixup even for the pkey path which is
quite surprising to me. I guess my misunderstanding comes from
Documentation/x86/protection-keys.txt
"
Memory Protection Keys provides a mechanism for enforcing page-based
protections, but without requiring modification of the page tables
when an application changes protection domains.  It works by
dedicating 4 previously ignored bits in each page table entry to a
"protection key", giving 16 possible keys.
"

So please disregard my previous comments about page tables and sorry
about the confusion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

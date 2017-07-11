Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B006F6810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 17:52:28 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o8so2427535qtc.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:52:28 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id h43si508887qth.45.2017.07.11.14.52.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 14:52:27 -0700 (PDT)
Message-ID: <1499808649.2865.31.camel@kernel.crashing.org>
Subject: Re: [RFC v5 00/38] powerpc: Memory Protection Keys
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 12 Jul 2017 07:30:49 +1000
In-Reply-To: <20170711193257.GB5525@ram.oc3035372033.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
	 <20170711145246.GA11917@dhcp22.suse.cz>
	 <20170711193257.GB5525@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Tue, 2017-07-11 at 12:32 -0700, Ram Pai wrote:
> Ideally the MMU looks at the PTE for keys, in order to enforce
> protection. This is the case with x86 and is the case with power9 Radix
> page table. Hence the keys have to be programmed into the PTE.

POWER9 radix doesn't currently support keys.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id CD1706B0069
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 10:49:39 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id hz20so1982579lab.25
        for <linux-mm@kvack.org>; Sat, 18 Oct 2014 07:49:39 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id o1si6511204lbw.57.2014.10.18.07.49.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 18 Oct 2014 07:49:38 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Sat, 18 Oct 2014 15:49:36 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 005C21B08049
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 15:50:54 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9IEnYGb19005948
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 14:49:34 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9IEnWS2003779
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 08:49:34 -0600
Date: Sat, 18 Oct 2014 16:49:28 +0200
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] mm: introduce new VM_NOZEROPAGE flag
Message-ID: <20141018164928.2341415f@BR9TG4T3.de.ibm.com>
In-Reply-To: <54419265.9000000@intel.com>
References: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>
	<1413554990-48512-3-git-send-email-dingel@linux.vnet.ibm.com>
	<54419265.9000000@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

On Fri, 17 Oct 2014 15:04:21 -0700
Dave Hansen <dave.hansen@intel.com> wrote:
 
> Is there ever a time where the VMAs under an mm have mixed VM_NOZEROPAGE
> status?  Reading the patches, it _looks_ like it might be an all or
> nothing thing.

Currently it is an all or nothing thing, but for a future change we might want to just
tag the guest memory instead of the complete user address space.

> Full disclosure: I've got an x86-specific feature I want to steal a flag
> for.  Maybe we should just define another VM_ARCH bit.
> 

So you think of something like:

#if defined(CONFIG_S390)
# define VM_NOZEROPAGE	VM_ARCH_1
#endif

#ifndef VM_NOZEROPAGE
# define VM_NOZEROPAGE	VM_NONE
#endif

right?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

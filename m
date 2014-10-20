Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 010496B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 14:15:01 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id x13so6030240wgg.18
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:15:00 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id fl4si9306379wib.99.2014.10.20.11.14.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 11:14:59 -0700 (PDT)
Received: by mail-wi0-f180.google.com with SMTP id em10so7099944wid.13
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:14:59 -0700 (PDT)
Message-ID: <5445511D.1090603@redhat.com>
Date: Mon, 20 Oct 2014 20:14:53 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: introduce new VM_NOZEROPAGE flag
References: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>	<1413554990-48512-3-git-send-email-dingel@linux.vnet.ibm.com>	<54419265.9000000@intel.com> <20141018164928.2341415f@BR9TG4T3.de.ibm.com> <54429521.80402@intel.com>
In-Reply-To: <54429521.80402@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

On 10/18/2014 06:28 PM, Dave Hansen wrote:
> > Currently it is an all or nothing thing, but for a future change we might want to just
> > tag the guest memory instead of the complete user address space.
>
> I think it's a bad idea to reserve a flag for potential future use.  If
> you_need_  it in the future, let's have the discussion then.  For now, I
> think it should probably just be stored in the mm somewhere.

I agree with Dave (I thought I disagreed, but I changed my mind while 
writing down my thoughts).  Just define mm_forbids_zeropage in 
arch/s390/include/asm, and make it return mm->context.use_skey---with a 
comment explaining how this is only for processes that use KVM, and then 
only for guests that use storage keys.

Paolo (who was just taught what storage keys really are)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

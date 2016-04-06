Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A0C606B026D
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 02:47:11 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id v188so11629936wme.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 23:47:11 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id y3si1585418wjy.136.2016.04.05.23.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 23:47:10 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id n3so10333747wmn.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 23:47:10 -0700 (PDT)
Subject: Re: [PATCH 17/31] kvm: teach kvm to map page teams as huge pages.
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051439340.5965@eggly.anvils>
 <57044C3A.7060109@redhat.com>
 <alpine.LSU.2.11.1604051756020.7348@eggly.anvils>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <5704B0E4.9060300@redhat.com>
Date: Wed, 6 Apr 2016 08:47:00 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1604051756020.7348@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org



On 06/04/2016 03:12, Hugh Dickins wrote:
> Hah, you've lighted on precisely a line of code where I changed around
> what Andres had - I thought it nicer to pass down vcpu, because that
> matched the function above, and in many cases vcpu is not dereferenced
> here at all.  So, definitely blame me not Andres for that interface.
> 

Oh, actually I'm fine with the interface if it's in arch/x86/kvm.  I'm
just pointing out that---putting aside the locking question---it's a
pretty generic thing that doesn't really need access to KVM data structures.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

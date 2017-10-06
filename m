Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5964D6B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 00:28:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q203so12365930wmb.0
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 21:28:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b23si846968edj.341.2017.10.05.21.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 21:28:51 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v964SnSn006181
	for <linux-mm@kvack.org>; Fri, 6 Oct 2017 00:28:49 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2de2m28jkm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 06 Oct 2017 00:28:49 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 6 Oct 2017 05:28:46 +0100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v964Sg7u15794220
	for <linux-mm@kvack.org>; Fri, 6 Oct 2017 04:28:43 GMT
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v964Sgx4029257
	for <linux-mm@kvack.org>; Fri, 6 Oct 2017 15:28:43 +1100
Subject: Re: [PATCH] kvm, mm: account kvm related kmem slabs to kmemcg
References: <20171006010724.186563-1-shakeelb@google.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 6 Oct 2017 09:58:30 +0530
MIME-Version: 1.0
In-Reply-To: <20171006010724.186563-1-shakeelb@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <a6707959-fe38-0bf6-5281-1c60ba63bc8c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, x86@kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On 10/06/2017 06:37 AM, Shakeel Butt wrote:
> The kvm slabs can consume a significant amount of system memory
> and indeed in our production environment we have observed that
> a lot of machines are spending significant amount of memory that
> can not be left as system memory overhead. Also the allocations
> from these slabs can be triggered directly by user space applications
> which has access to kvm and thus a buggy application can leak
> such memory. So, these caches should be accounted to kmemcg.

But there may be other situations like this where user space can
trigger allocation from various SLAB objects inside the kernel
which are accounted as system memory. So how we draw the line
which ones should be accounted for memcg. Just being curious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

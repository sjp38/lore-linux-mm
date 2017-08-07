Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 392016B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 05:37:34 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id i19so40718085qte.5
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 02:37:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g141si6712928qke.458.2017.08.07.02.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 02:37:33 -0700 (PDT)
Subject: Re: [PATCH RESEND] mm: don't zero ballooned pages
References: <1501761557-9758-1-git-send-email-wei.w.wang@intel.com>
 <9ac31505-0996-2822-752e-8ec055373aa0@redhat.com>
 <20170807092525.GE32434@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <8b862c93-1a9f-9247-8401-5092cc35a857@redhat.com>
Date: Mon, 7 Aug 2017 11:37:26 +0200
MIME-Version: 1.0
In-Reply-To: <20170807092525.GE32434@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, zhenwei.pi@youruncloud.com, dave.hansen@intel.com, akpm@linux-foundation.org, mawilcox@microsoft.com, Andrea Arcangeli <aarcange@redhat.com>

> Maybe it is my absolute lack of familiarity with what the host actually
> does with balloon pages but I fail to see why the above matters at all.
> ksm will not try to merge sub page units (4k for hugetlb or a large base
> page). And if you need to hide the guest contents then the host can
> clear the respective subpage just fine. So could you be more explicit
> why MADV_DONTNEED matters at all? Also does any host actually share sub
> pages between different guests? This sounds like a bad idea to me in
> general.
> 

Okay, I think I got the issue wrong. I thought that the original patch
tried to also fix a corner case where the guest would assume that it
would get supplied zero pages afterwards. Please ignore the noise. :)

-- 

Thanks,

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

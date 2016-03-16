Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B8FDC6B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 11:54:17 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id l124so54037837wmf.1
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 08:54:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g2si4343427wje.67.2016.03.16.08.54.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Mar 2016 08:54:16 -0700 (PDT)
Subject: Re: [PATCH v3 1/2] mm, vmstat: calculate particular vm event
References: <1457991611-6211-1-git-send-email-ebru.akagunduz@gmail.com>
 <1457991611-6211-2-git-send-email-ebru.akagunduz@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E981A5.30401@suse.cz>
Date: Wed, 16 Mar 2016 16:54:13 +0100
MIME-Version: 1.0
In-Reply-To: <1457991611-6211-2-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On 03/14/2016 10:40 PM, Ebru Akagunduz wrote:
> Currently, vmstat can calculate specific vm event with all_vm_events()
> however it allocates all vm events to stack. This patch introduces
> a helper to sum value of a specific vm event over all cpu, without
> loading all the events.
>
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Kirill was modest enough to not point this out, but this should IMHO 
have at least:

Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Otherwise:
Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

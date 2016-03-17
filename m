Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 912FD6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 04:49:30 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id p65so15475247wmp.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 01:49:30 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id c12si35684141wmd.117.2016.03.17.01.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 01:49:29 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id p65so15474682wmp.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 01:49:29 -0700 (PDT)
Message-ID: <56ea6f98.418f1c0a.cb040.ffffa357@mx.google.com>
Date: Thu, 17 Mar 2016 10:49:28 +0200
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [PATCH v3 1/2] mm, vmstat: calculate particular vm event
References: <1457991611-6211-1-git-send-email-ebru.akagunduz@gmail.com>
 <1457991611-6211-2-git-send-email-ebru.akagunduz@gmail.com>
 <56E981A5.30401@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E981A5.30401@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On Wed, Mar 16, 2016 at 04:54:13PM +0100, Vlastimil Babka wrote:
> On 03/14/2016 10:40 PM, Ebru Akagunduz wrote:
> >Currently, vmstat can calculate specific vm event with all_vm_events()
> >however it allocates all vm events to stack. This patch introduces
> >a helper to sum value of a specific vm event over all cpu, without
> >loading all the events.
> >
> >Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> >Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Kirill was modest enough to not point this out, but this should IMHO
> have at least:
> 
> Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Otherwise:
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
Sure. I'll add Suggested-by in next version.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

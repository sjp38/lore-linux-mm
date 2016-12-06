Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17EC86B025E
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 03:40:55 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id w39so238491968qtw.0
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 00:40:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v199si11166011qkb.327.2016.12.06.00.40.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 00:40:54 -0800 (PST)
Subject: Re: [PATCH kernel v5 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
Date: Tue, 6 Dec 2016 09:40:47 +0100
MIME-Version: 1.0
In-Reply-To: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, kvm@vger.kernel.org
Cc: virtio-dev@lists.oasis-open.org, mhocko@suse.com, mst@redhat.com, dave.hansen@intel.com, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, pbonzini@redhat.com, akpm@linux-foundation.org, virtualization@lists.linux-foundation.org, dgilbert@redhat.com

Am 30.11.2016 um 09:43 schrieb Liang Li:
> This patch set contains two parts of changes to the virtio-balloon.
>
> One is the change for speeding up the inflating & deflating process,
> the main idea of this optimization is to use bitmap to send the page
> information to host instead of the PFNs, to reduce the overhead of
> virtio data transmission, address translation and madvise(). This can
> help to improve the performance by about 85%.

Do you have some statistics/some rough feeling how many consecutive bits 
are usually set in the bitmaps? Is it really just purely random or is 
there some granularity that is usually consecutive?

IOW in real examples, do we have really large consecutive areas or are 
all pages just completely distributed over our memory?

Thanks!

-- 

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

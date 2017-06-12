Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B38126B02C3
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 12:42:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e1so54946779pga.5
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 09:42:39 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v32si7137918plb.497.2017.06.12.09.42.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 09:42:38 -0700 (PDT)
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
 <20170612181354-mutt-send-email-mst@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9d0900f3-9df5-ac63-4069-2d796f2a5bc7@intel.com>
Date: Mon, 12 Jun 2017 09:42:36 -0700
MIME-Version: 1.0
In-Reply-To: <20170612181354-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 06/12/2017 09:28 AM, Michael S. Tsirkin wrote:
> 
>> The hypervisor is going to throw away the contents of these pages,
>> right?
> It should be careful and only throw away contents that was there before
> report_unused_page_block was invoked.  Hypervisor is responsible for not
> corrupting guest memory.  But that's not something an mm patch should
> worry about.

That makes sense.  I'm struggling to imagine how the hypervisor makes
use of this information, though.  Does it make the pages read-only
before this, and then it knows if there has not been a write *and* it
gets notified via this new mechanism that it can throw the page away?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

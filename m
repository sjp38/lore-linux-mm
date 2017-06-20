Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9390E6B02C3
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:02:10 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v20so85159640qtg.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:02:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 4si12611792qkl.155.2017.06.20.12.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 12:02:09 -0700 (PDT)
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
 <1497977049.20270.100.camel@redhat.com>
 <7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com>
 <20170620211445-mutt-send-email-mst@kernel.org>
 <f46768db-dcda-aa40-64b9-eb2929249db8@redhat.com>
 <20170620215552-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <338ec5ce-759b-6381-0442-ac0741f159b8@redhat.com>
Date: Tue, 20 Jun 2017 21:01:58 +0200
MIME-Version: 1.0
In-Reply-To: <20170620215552-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, Nitesh Narayan Lal <nilal@redhat.com>


>> IMHO even simply writing all-zeros to all free pages before starting
>> migration (or even when freeing a page) would be a cleaner interface
>> than this (because it atomically works with the entity the host cares
>> about for migration). But yes, performance is horrible that's why I am
>> not even suggesting it. Just saying that this mm interface is very very
>> special and if we could find something better, I'd favor it.
> 
> As long as there's a single user, changing to a better interface
> once it's found won't be hard at all :)
> 

Hehe, more like "we made this beautiful virtio-balloon extension" - oh
there is free page hinting (assuming that it does not reuse the batch
interface here). Guess how long it would take to at least show that free
page hinting can be done. If it takes another 6 years, I am totally on
your side ;)

-- 

Thanks,

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

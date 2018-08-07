Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 316A56B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 10:16:40 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u68-v6so16881052qku.5
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 07:16:40 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s63-v6si1378382qkc.404.2018.08.07.07.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 07:16:39 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] Do not touch pages in remove_memory path
References: <20180807133757.18352-1-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <6407d022-87b7-f5e0-572a-c5c29aba1314@redhat.com>
Date: Tue, 7 Aug 2018 16:16:35 +0200
MIME-Version: 1.0
In-Reply-To: <20180807133757.18352-1-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, jglisse@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 07.08.2018 15:37, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> This tries to fix [1], which was reported by David Hildenbrand, and also
> does some cleanups/refactoring.
> 
> I am sending this as RFC to see if the direction I am going is right before
> spending more time into it.
> And also to gather feedback about hmm/zone_device stuff.
> The code compiles and I tested it successfully with normal memory-hotplug operations.
>

Please coordinate next time with people already working on this,
otherwise you might end up wasting other people's time.

Anyhow, thanks for looking into this.

-- 

Thanks,

David / dhildenb

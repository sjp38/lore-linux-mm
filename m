Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 119296B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 13:09:37 -0400 (EDT)
Received: by ykfw194 with SMTP id w194so101231377ykf.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:09:36 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id n124si15912264ywe.197.2015.07.28.10.09.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 10:09:36 -0700 (PDT)
Message-ID: <55B7B74A.8080207@citrix.com>
Date: Tue, 28 Jul 2015 18:09:30 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: vmemmap_verify() BUGs during memory hotplug (4.2-rc1 regression)
References: <55B64F1D.8090807@citrix.com> <20150727154146.GP2561@suse.de>
In-Reply-To: <20150727154146.GP2561@suse.de>
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 27/07/15 16:41, Mel Gorman wrote:
> On Mon, Jul 27, 2015 at 04:32:45PM +0100, David Vrabel wrote:
>> Mel,
>>
>> As of commit 8a942fdea560d4ac0e9d9fabcd5201ad20e0c382 (mm: meminit: make
>> __early_pfn_to_nid SMP-safe and introduce meminit_pfn_in_nid)
>> vmemmap_verify() will BUG_ON() during memory hotplug because of its use
>> of early_pfn_to_nid().  Previously, it would have reported bogus (or
>> failed to report valid) warnings.
>>
> 
> Please test "mm, meminit: Allow early_pfn_to_nid to be used during
> runtime"

That fixed the BUG_ON() thanks.  But I still can't only the new sections
because their first page is not reserved, but I've not had time to
investigate why this is yet.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

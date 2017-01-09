Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 632566B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 11:21:32 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so83461509pfb.6
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 08:21:32 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y2si89173196pfk.286.2017.01.09.08.21.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 08:21:31 -0800 (PST)
Subject: Re: [HMM v15 01/16] mm/free_hot_cold_page: catch ZONE_DEVICE pages
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
 <1483721203-1678-2-git-send-email-jglisse@redhat.com>
 <20170109091952.GA9655@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <591ef5e3-54a9-da61-bca6-f30641bebe88@intel.com>
Date: Mon, 9 Jan 2017 08:21:25 -0800
MIME-Version: 1.0
In-Reply-To: <20170109091952.GA9655@localhost.localdomain>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 01/09/2017 01:19 AM, Balbir Singh wrote:
>> +	/*
>> +	 * This should never happen ! Page from ZONE_DEVICE always must have an
>> +	 * active refcount. Complain about it and try to restore the refcount.
>> +	 */
>> +	if (is_zone_device_page(page)) {
>> +		VM_BUG_ON_PAGE(is_zone_device_page(page), page);
> This can be VM_BUG_ON_PAGE(1, page), hopefully the compiler does the right thing
> here. I suspect this should be a BUG_ON, independent of CONFIG_DEBUG_VM

BUG_ON() means "kill the machine dead".  Do we really want a guaranteed
dead machine if someone screws up their refcounting?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

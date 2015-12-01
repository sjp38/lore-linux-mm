Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 633D26B0253
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 12:02:30 -0500 (EST)
Received: by qkda6 with SMTP id a6so5069932qkd.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 09:02:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y19si50870168qhb.115.2015.12.01.09.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 09:02:29 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v3 1/3] resource: Add @flags to region_intersects()
References: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
	<1448404418-28800-2-git-send-email-toshi.kani@hpe.com>
	<20151201135000.GB4341@pd.tnic>
	<CAPcyv4g2n9yTWye2aVvKMP0X7mrm_NLKmGd5WBO2SesTj77gbg@mail.gmail.com>
Date: Tue, 01 Dec 2015 12:02:26 -0500
In-Reply-To: <CAPcyv4g2n9yTWye2aVvKMP0X7mrm_NLKmGd5WBO2SesTj77gbg@mail.gmail.com>
	(Dan Williams's message of "Tue, 1 Dec 2015 08:54:23 -0800")
Message-ID: <x49y4dekspp.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, Tony Luck <tony.luck@intel.com>, Linux ACPI <linux-acpi@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

Dan Williams <dan.j.williams@intel.com> writes:

>>> @@ -57,7 +57,7 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
>>>   */
>>>  void *memremap(resource_size_t offset, size_t size, unsigned long flags)
>>>  {
>>> -     int is_ram = region_intersects(offset, size, "System RAM");
>>
>> Ok, question: why do those resource things types gets identified with
>> a string?! We have here "System RAM" and next patch adds "Persistent
>> Memory".
>>
>> And "persistent memory" or "System RaM" won't work and this is just
>> silly.
>>
>> Couldn't struct resource have gained some typedef flags instead which we
>> can much easily test? Using the strings looks really yucky.
>>
>
> At least in the case of region_intersects() I was just following
> existing strcmp() convention from walk_system_ram_range.

...which is done in the page fault path.  I agree with the suggestion to
get strcmp out of that path.

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

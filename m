Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFDBB6B02A3
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:26:55 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id w107so136562765ota.6
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 10:26:55 -0800 (PST)
Received: from mail-ot0-x22d.google.com (mail-ot0-x22d.google.com. [2607:f8b0:4003:c0f::22d])
        by mx.google.com with ESMTPS id 108si7837824otu.26.2017.01.24.10.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 10:26:54 -0800 (PST)
Received: by mail-ot0-x22d.google.com with SMTP id 73so133937088otj.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 10:26:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170124111248.GC20153@quack2.suse.cz>
References: <148521477073.31533.17781371321988910714.stgit@djiang5-desk3.ch.intel.com>
 <20170124111248.GC20153@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 24 Jan 2017 10:26:54 -0800
Message-ID: <CAPcyv4gW7cho=eE4BQZQ69J7ehREurP6CPbQX3z6eW7BUVT3Bw@mail.gmail.com>
Subject: Re: [PATCH 0/3] 1G transparent hugepage support for device dax
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Jiang <dave.jiang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Jan 24, 2017 at 3:12 AM, Jan Kara <jack@suse.cz> wrote:
> On Mon 23-01-17 16:47:18, Dave Jiang wrote:
>> The following series implements support for 1G trasparent hugepage on
>> x86 for device dax. The bulk of the code was written by Mathew Wilcox
>> a while back supporting transparent 1G hugepage for fs DAX. I have
>> forward ported the relevant bits to 4.10-rc. The current submission has
>> only the necessary code to support device DAX.
>
> Well, you should really explain why do we want this functionality... Is
> anybody going to use it? Why would he want to and what will he gain by
> doing so? Because so far I haven't heard of a convincing usecase.
>

So the motivation and intended user of this functionality mirrors the
motivation and users of 1GB page support in hugetlbfs. Given expected
capacities of persistent memory devices an in-memory database may want
to reduce tlb pressure beyond what they can already achieve with 2MB
mappings of a device-dax file. We have customer feedback to that
effect as Willy mentioned in his previous version of these patches
[1].

[1]: https://lkml.org/lkml/2016/1/31/52

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 621256B025E
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:25:44 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 73so2372167otj.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 22:25:44 -0800 (PST)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id f13si10978906otd.254.2017.01.17.22.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 22:25:43 -0800 (PST)
Received: by mail-oi0-x22e.google.com with SMTP id u143so1978441oif.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 22:25:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170118060740.GE18349@bombadil.infradead.org>
References: <20170114002008.GA25379@linux.intel.com> <20170118052533.GA18349@bombadil.infradead.org>
 <CAPcyv4jNz=1QdPPtM2A=3avGtVvZG=2d9JC-JD_F6u+-CYQN4g@mail.gmail.com> <20170118060740.GE18349@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 17 Jan 2017 22:25:42 -0800
Message-ID: <CAPcyv4gvMzPbqpotKTRYhuiRgKRUz-Xrz81MFjpBmh3i=8euFQ@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@bombadil.infradead.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Tue, Jan 17, 2017 at 10:07 PM,  <willy@bombadil.infradead.org> wrote:
> On Tue, Jan 17, 2017 at 10:01:30PM -0800, Dan Williams wrote:
>> >> - Jan suggested [2] that we could use the radix tree as a cache to service DAX
>> >>   faults without needing to call into the filesystem.  Are there any issues
>> >>   with this approach, and should we move forward with it as an optimization?
>> >
>> > Ahem.  I believe I proposed this at last year's LSFMM.  And I sent
>> > patches to start that work.  And Dan blocked it.  So I'm not terribly
>> > amused to see somebody else given credit for the idea.
>>
>> I "blocked" moving the phys to virt translation out of the driver
>> since that mapping lifetime is device specific.
>
> The problem is that DAX currently assumes that there *is* a block driver,
> and it might be a char device or no device at all (the two examples I
> gave earlier).
>
>> However, I think caching the file offset to physical sector/address
>> result is a great idea.
>
> OK, great.  The lifetime problem I think you care about (hotplug) can be
> handled by removing all the cached entries for every file on every file
> on that block device ... I know there were prototype patches for that;
> did they ever get merged?

No, they didn't.. The last review comment was from Al. He wanted the
mechanism converted from explicit calls at del_gendisk() time into a
notifier chain since it's not just filesystems that may want to
register for a block-device end-of-life event.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

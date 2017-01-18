Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2A056B0260
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:01:31 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id 104so2173135otd.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 22:01:31 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id u129si10945443oia.40.2017.01.17.22.01.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 22:01:31 -0800 (PST)
Received: by mail-oi0-x232.google.com with SMTP id w204so1826767oiw.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 22:01:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170118052533.GA18349@bombadil.infradead.org>
References: <20170114002008.GA25379@linux.intel.com> <20170118052533.GA18349@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 17 Jan 2017 22:01:30 -0800
Message-ID: <CAPcyv4jNz=1QdPPtM2A=3avGtVvZG=2d9JC-JD_F6u+-CYQN4g@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@bombadil.infradead.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Tue, Jan 17, 2017 at 9:25 PM,  <willy@bombadil.infradead.org> wrote:
> On Fri, Jan 13, 2017 at 05:20:08PM -0700, Ross Zwisler wrote:
>> We still have a lot of work to do, though, and I'd like to propose a discussion
>> around what features people would like to see enabled in the coming year as
>> well as what what use cases their customers have that we might not be aware of.
>
> +1 to the discussion
>
>> - Jan suggested [2] that we could use the radix tree as a cache to service DAX
>>   faults without needing to call into the filesystem.  Are there any issues
>>   with this approach, and should we move forward with it as an optimization?
>
> Ahem.  I believe I proposed this at last year's LSFMM.  And I sent
> patches to start that work.  And Dan blocked it.  So I'm not terribly
> amused to see somebody else given credit for the idea.
>

I "blocked" moving the phys to virt translation out of the driver
since that mapping lifetime is device specific.

However, I think caching the file offset to physical sector/address
result is a great idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

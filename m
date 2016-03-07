Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id D4ECC6B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 12:18:43 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id m82so84021209oif.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 09:18:43 -0800 (PST)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id d127si12731345oif.101.2016.03.07.09.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 09:18:43 -0800 (PST)
Received: by mail-oi0-x22e.google.com with SMTP id d205so84075658oia.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 09:18:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1457373413.15454.334.camel@hpe.com>
References: <20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20160303215315.1014.95661.stgit@dwillia2-desk3.amr.corp.intel.com>
	<1457146138.15454.277.camel@hpe.com>
	<CAA9_cmc9vjChKqs7P1NG9r66TGapw0cYHfcajWh_O+hk433MTg@mail.gmail.com>
	<1457373413.15454.334.camel@hpe.com>
Date: Mon, 7 Mar 2016 09:18:42 -0800
Message-ID: <CAPcyv4i2vtdz8BGGBWR2eGXhW8nuA9w+gvGJN5P__Ks_PyyRRg@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] libnvdimm, pmem: adjust for section collisions
 with 'System RAM'
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Mar 7, 2016 at 9:56 AM, Toshi Kani <toshi.kani@hpe.com> wrote:
> On Fri, 2016-03-04 at 18:23 -0800, Dan Williams wrote:
>> On Fri, Mar 4, 2016 at 6:48 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
[..]
>> As far as I can see
>> all we do is ask firmware implementations to respect Linux section
>> boundaries and otherwise not change alignments.
>
> In addition to the requirement that pmem range alignment may not change,
> the code also requires a regular memory range does not change to intersect
> with a pmem section later.  This seems fragile to me since guest config may
> vary / change as I mentioned above.
>
> So, shouldn't the driver fails to attach when the range is not aligned by
> the section size?  Since we need to place a requirement to firmware anyway,
> we can simply state that it must be aligned by 128MiB (at least) on x86.
>  Then, memory and pmem physical layouts can be changed as long as this
> requirement is met.

We can state that it must be aligned, but without a hard specification
I don't see how we can guarantee it.  We will fail the driver load
with a warning if our alignment fixups end up getting invalidated by a
later configuration change, but in the meantime we cover the gap of a
BIOS that has generated a problematic configuration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

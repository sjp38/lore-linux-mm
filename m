Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 67C996B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 16:30:31 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w78so291093233oie.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 13:30:31 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id y6si10214615oia.244.2016.09.06.13.30.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 13:30:19 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id s131so55294302oie.2
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 13:30:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160906132001.cd465767fa9844ddeb630cc4@linux-foundation.org>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147318058712.30325.12749411762275637099.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160906132001.cd465767fa9844ddeb630cc4@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 6 Sep 2016 13:30:19 -0700
Message-ID: <CAPcyv4idFA_QDpgHd0jgz_J=dBqDNRtBQuntXanJcaiNa-z9ww@mail.gmail.com>
Subject: Re: [PATCH 5/5] mm: cleanup pfn_t usage in track_pfn_insert()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Sep 6, 2016 at 1:20 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 06 Sep 2016 09:49:47 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
>
>> Now that track_pfn_insert() is no longer used in the DAX path, it no
>> longer needs to comprehend pfn_t values.
>
> What's the benefit in this?  A pfn *should* have type pfn_t, shouldn't
> it?   Confused.

It should when there's extra information to consider.  I don't mind
leaving it as is, but all the other usages of pfn_t are considering or
passing through the PFN_DEV and PFN_MAP flags.  So, it's a courtesy to
the reader saying "you don't need to worry about pfn_t defined
behavior here, this is just a plain old physical address >>
PAGE_SHIFT"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

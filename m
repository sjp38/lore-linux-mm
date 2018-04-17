Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E08A6B0006
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:08:52 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id i124-v6so10272566oib.3
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 21:08:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a8-v6sor6705614oti.293.2018.04.16.21.08.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 21:08:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180417001907.GB25048@bombadil.infradead.org>
References: <20180414155059.GA18015@jordon-HP-15-Notebook-PC>
 <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com>
 <20180417001421.GH22870@thunk.org> <20180417001907.GB25048@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Apr 2018 21:08:50 -0700
Message-ID: <CAPcyv4jYbmEEWYEhn8epDVQL=L7_cx3g7F5MNAqq6P7hTpJoOg@mail.gmail.com>
Subject: Re: [PATCH] dax: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Souptick Joarder <jrdr.linux@gmail.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Mon, Apr 16, 2018 at 5:19 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Mon, Apr 16, 2018 at 08:14:22PM -0400, Theodore Y. Ts'o wrote:
>> On Mon, Apr 16, 2018 at 09:14:48AM -0700, Dan Williams wrote:
>> > Ugh, so this change to vmf_insert_mixed() went upstream without fixing
>> > the users? This changelog is now misleading as it does not mention
>> > that is now an urgent standalone fix. On first read I assumed this was
>> > part of a wider effort for 4.18.
>>
>> Why is this an urgent fix?  I thought all the return type change was
>> did something completely innocuous that would not cause any real
>> difference.
>
> Keep reading the thread; Dan is mistaken.

Yes, false alarm, sorry. But we at least got a better changelog for the trouble.

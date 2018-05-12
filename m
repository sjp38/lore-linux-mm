Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64D246B06F3
	for <linux-mm@kvack.org>; Sat, 12 May 2018 15:14:26 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id z18-v6so2875250lfg.17
        for <linux-mm@kvack.org>; Sat, 12 May 2018 12:14:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p74-v6sor1391181lfe.93.2018.05.12.12.14.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 12 May 2018 12:14:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180512142451.GB24215@bombadil.infradead.org>
References: <20180512061712.GA26660@jordon-HP-15-Notebook-PC>
 <e194731158f7f89145ed0ae28f46aac5726fc32d.camel@perches.com> <20180512142451.GB24215@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 13 May 2018 00:44:23 +0530
Message-ID: <CAFqt6zb9KzPw0ih3fOs6DNd3RCcy9GYmxZ607_w7obn0Kym7Kw@mail.gmail.com>
Subject: Re: [PATCH v3] mm: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

>> It'd be nicer to realign the 2nd and 3rd arguments
>> on the subsequent lines.

>>
>>       vm_fault_t (*fault)(const struct vm_special_mapping *sm,
>>                           struct vm_area_struct *vma,
>>                           struct vm_fault *vmf);
>>
>

> It'd be nicer if people didn't try to line up arguments at all and
> just indented by an extra two tabs when they had to break a logical
> line due to the 80-column limit.

Matthew, there are two different opinions. Which one to take ?

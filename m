Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA236B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 10:47:21 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 106so35326580otc.14
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 07:47:21 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id e206si3184335oib.0.2017.06.12.07.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 07:47:20 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id b6so2337532oia.1
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 07:47:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170612120714.zypyvp3e4zypqfvf@black.fi.intel.com>
References: <149713136649.17377.3742583729924020371.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149713137723.17377.8854203820807564559.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170612120714.zypyvp3e4zypqfvf@black.fi.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 12 Jun 2017 07:47:19 -0700
Message-ID: <CAPcyv4jb6Vqvm-rZ84z44LaoerMcJUZiR59TAiQ2itTqwb0j7A@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: always enable thp for dax mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Mon, Jun 12, 2017 at 5:07 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> On Sat, Jun 10, 2017 at 02:49:37PM -0700, Dan Williams wrote:
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index c4706e2c3358..901ed3767d1b 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -1,6 +1,8 @@
>>  #ifndef _LINUX_HUGE_MM_H
>>  #define _LINUX_HUGE_MM_H
>>
>> +#include <linux/fs.h>
>> +
>
> It means <linux/mm.h> now depends on <linux/fs.h>. I don't think it's a
> good idea.

Seems to be ok as far as 0day-kbuild-robot is concerned. The
alternative is to move vma_is_dax() out of line. I think
transparent_hugepage_enabled() is called frequently enough to make it
worth it to keep it inline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

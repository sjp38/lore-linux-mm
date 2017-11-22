Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EBD456B02B9
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 11:52:39 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id b10so2177563oif.22
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 08:52:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20sor6039509ota.140.2017.11.22.08.52.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 08:52:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <638b3b80-5cb9-97c2-5055-fef3a1ec25b9@suse.cz>
References: <20171101153648.30166-1-jack@suse.cz> <20171101153648.30166-2-jack@suse.cz>
 <638b3b80-5cb9-97c2-5055-fef3a1ec25b9@suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 22 Nov 2017 08:52:37 -0800
Message-ID: <CAPcyv4gGRHWc6AH5Enb7njtmqHgd=g+0-mYMdd5wWjJMW0+d7g@mail.gmail.com>
Subject: Re: [PATCH 01/18] mm: introduce MAP_SHARED_VALIDATE, a mechanism to
 safely define new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, "Darrick J . Wong" <darrick.wong@oracle.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Nov 22, 2017 at 4:02 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 11/01/2017 04:36 PM, Jan Kara wrote:
>> From: Dan Williams <dan.j.williams@intel.com>
>>
>> The mmap(2) syscall suffers from the ABI anti-pattern of not validating
>> unknown flags. However, proposals like MAP_SYNC need a mechanism to
>> define new behavior that is known to fail on older kernels without the
>> support. Define a new MAP_SHARED_VALIDATE flag pattern that is
>> guaranteed to fail on all legacy mmap implementations.
>
> So I'm trying to make sense of this together with Michal's attempt for
> MAP_FIXED_SAFE [1] where he has to introduce a completely new flag
> instead of flag modifier exactly for the reason of not validating
> unknown flags. And my conclusion is that because MAP_SHARED_VALIDATE
> implies MAP_SHARED and excludes MAP_PRIVATE, MAP_FIXED_SAFE as a
> modifier cannot build on top of this. Wouldn't thus it be really better
> long-term to introduce mmap3 at this point? ...

We have room to define MAP_PRIVATE_VALIDATE in MAP_TYPE on every arch
except parisc. Can we steal an extra bit for MAP_TYPE from somewhere
else on parisc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

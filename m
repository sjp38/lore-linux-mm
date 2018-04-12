Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB3D36B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 14:20:37 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p4so3420063wrf.17
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 11:20:37 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x23sor3472203edi.29.2018.04.12.11.20.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 11:20:32 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20180412142214.fcxw3g2jxv6bvn7d@quack2.suse.cz>
References: <20171101153648.30166-1-jack@suse.cz> <20171101153648.30166-20-jack@suse.cz>
 <CAKgNAkhsFrcdkXNA2cw3o0gJV0uLRtBg9ybaCe5xy1QBC2PgqA@mail.gmail.com> <20180412142214.fcxw3g2jxv6bvn7d@quack2.suse.cz>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Thu, 12 Apr 2018 20:20:12 +0200
Message-ID: <CAKgNAkgtVryFb81QgzwPq8SD241yKDN1xNxOWUUQH9QBYV13SA@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: Add description of MAP_SHARED_VALIDATE and MAP_SYNC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Ext4 Developers List <linux-ext4@vger.kernel.org>, xfs <linux-xfs@vger.kernel.org>, "Darrick J . Wong" <darrick.wong@oracle.com>

Jan, Ross.

On 12 April 2018 at 16:22, Jan Kara <jack@suse.cz> wrote:
> Hello Michael!
>
> On Thu 12-04-18 15:00:49, Michael Kerrisk (man-pages) wrote:
>> Hello Jan,
>>
>> I have applied your patch, and tweaked the text a little, and pushed
>> the result to the git repo.
>
> Thanks!
>
>> > +.B MAP_SHARED
>> > +type will silently ignore this flag.
>> > +This flag is supported only for files supporting DAX (direct mapping =
of persistent
>> > +memory). For other files, creating mapping with this flag results in
>> > +.B EOPNOTSUPP
>> > +error. Shared file mappings with this flag provide the guarantee that=
 while
>> > +some memory is writeably mapped in the address space of the process, =
it will
>> > +be visible in the same file at the same offset even after the system =
crashes or
>> > +is rebooted. This allows users of such mappings to make data modifica=
tions
>> > +persistent in a more efficient way using appropriate CPU instructions=
.
>>
>> It feels like there's a word missing/unclear wording in the previous
>> line, before "using". Without that word, the sentence feels a bit
>> ambiguous.
>>
>> Should it be:
>>
>> persistent in a more efficient way *through the use of* appropriate
>> CPU instructions.
>>
>> or:
>>
>> persistent in a more efficient way *than using* appropriate CPU instruct=
ions.
>>
>> ?
>>
>> Is suspect the first is correct, but need to check.
>
> Yes, the first is correct.

Thanks for both checking that phrasing. In the end I decided to reword
the sentence a bot more substantially:

              In  conjunction  with  the  use of appropriate CPU
              instructions, this provides users of such mappings
              with a more efficient way of making data modifica=E2=80=90
              tions persistent.

Thanks,

Michael

--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

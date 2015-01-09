Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id CCD3E6B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 14:30:54 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id q108so10483840qgd.6
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 11:30:54 -0800 (PST)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com. [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id k32si13386086qge.43.2015.01.09.11.30.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 11:30:53 -0800 (PST)
Received: by mail-qa0-f44.google.com with SMTP id w8so699916qac.3
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 11:30:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150108114950.GB3351@infradead.org>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <20141210140347.GA23252@infradead.org> <20141210141211.GD2220@wil.cx>
 <20150105184143.GA665@infradead.org> <20150106004714.6d63023c.akpm@linux-foundation.org>
 <20150108114950.GB3351@infradead.org>
From: Steve French <smfrench@gmail.com>
Date: Fri, 9 Jan 2015 13:30:31 -0600
Message-ID: <CAH2r5mtwQEJ1q=a_4TSQyY=Qt7TZ7Dtj9oVGfCHJ+Enrj8v5qQ@mail.gmail.com>
Subject: Re: pread2/ pwrite2
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Milosz Tanski <milosz@adfin.com>

On Thu, Jan 8, 2015 at 5:49 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Jan 06, 2015 at 12:47:14AM -0800, Andrew Morton wrote:
>> > progress, which is a bit frustrating.
>>
>> I took a look at pread2() as well and I have two main issues:
>>
>> - The patchset includes a pwrite2() syscall which has nothing to do
>>   with nonblocking reads and which was poorly described and had little
>>   justification for inclusion.
>
> It allows to do O_SYNC writes on a per-I/O basis.  This is very useful
> for file servers (smb, cifs) as well as storage target devices.

This would be particularly useful for SMB3 as the protocol now allows
write-through vs. no-write-through flag on every write request (not just
on an open, it can be changed on a particular i/o to write-through).
There is also a cache/no-cache hint that can be sent on reads/writes in
the newest SMB3 dialect well (but it is less clear to me how we would
ever decide to set that on the Linux client).




-- 
Thanks,

Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

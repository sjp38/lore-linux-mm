Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id D50016B0003
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 00:18:34 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id i13-v6so801875oth.4
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 21:18:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s30-v6si1985139otb.106.2018.06.27.21.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 21:18:33 -0700 (PDT)
Subject: Re: [PATCH] mm: reject MAP_SHARED_VALIDATE without new flags
References: <60052659-7b37-cb69-bf9f-1683caa46219@redhat.com>
 <CA+55aFzeA7N3evSF2jKHu8JoTQuKDLCMKx7RiPhmym97-8HY7A@mail.gmail.com>
 <1e2ad827-6ff4-4b1e-c4d9-79ca4e432a6c@sandeen.net>
 <CA+55aFxs7Cc30fCiENw0R+XDJhUJ-w=z=NLLzYfT5gF2Qh-60Q@mail.gmail.com>
From: Eric Sandeen <sandeen@redhat.com>
Message-ID: <52d82353-2746-269a-c1e3-e4aec4fbf0f9@redhat.com>
Date: Wed, 27 Jun 2018 23:18:30 -0500
MIME-Version: 1.0
In-Reply-To: <CA+55aFxs7Cc30fCiENw0R+XDJhUJ-w=z=NLLzYfT5gF2Qh-60Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Eric Sandeen <sandeen@sandeen.net>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, linux-ext4@vger.kernel.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, zhibli@redhat.com

On 6/27/18 9:37 PM, Linus Torvalds wrote:
> On Wed, Jun 27, 2018 at 7:17 PM Eric Sandeen <sandeen@sandeen.net> wrote:
>>
>> What broke is that mmap(MAP_SHARED|MAP_PRIVATE) now succeeds without error,
>> whereas before it rightly returned -EINVAL.
> 
> You're still confusing *behavior* with breakage.
> 
> Yes. New *behavior* is that MAP_SHARED|MAP_PRIVATE is now a valid
> thing. It means "MAP_SHARED_VALIDATE".
> 
> Behavior changed.  That's normal. Every single time we add a system
> call, behavior changes: a system call that used to return -ENOSYS now
> returns something else.
> 
> That's not breakage, that's just intentional new behavior.

*shrug* semantics aside, the new behavior is out there in a public
API, so I guess there's nothing to do at this point other than
to document the change more clearly.  It's true that my patch could
possibly break existing users.

The man page is clearly wrong at this point, both in terms of the
error code section, and the claim that MAP_SHARED and MAP_PRIVATE
behave as described in POSIX (because POSIX states that these
two flags may not be specified together.)

-Eric

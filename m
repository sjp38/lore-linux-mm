Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA0B6B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 11:21:58 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id k76so14733301iod.12
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 08:21:58 -0800 (PST)
Received: from sandeen.net (sandeen.net. [63.231.237.45])
        by mx.google.com with ESMTP id d18si2384657ioc.18.2018.01.31.08.21.56
        for <linux-mm@kvack.org>;
        Wed, 31 Jan 2018 08:21:56 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] Patch Submission process and Handling Internal
 Conflict
References: <1516820744.3073.30.camel@HansenPartnership.com>
 <c4598a9a-6995-d67a-dd1c-8e946470eeb4@oracle.com>
 <1516829760.3073.43.camel@HansenPartnership.com>
 <20180124234347.GA11926@magnolia>
From: Eric Sandeen <sandeen@sandeen.net>
Message-ID: <f560f236-9bee-4aa7-9455-3a548f765edb@sandeen.net>
Date: Wed, 31 Jan 2018 10:21:55 -0600
MIME-Version: 1.0
In-Reply-To: <20180124234347.GA11926@magnolia>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>, James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On 1/24/18 5:43 PM, Darrick J. Wong wrote:
> On Wed, Jan 24, 2018 at 01:36:00PM -0800, James Bottomley wrote:
>> On Wed, 2018-01-24 at 11:20 -0800, Mike Kravetz wrote:
>>> On 01/24/2018 11:05 AM, James Bottomley wrote:
>>>>
>>>> I've got two community style topics, which should probably be
>>>> discussed
>>>> in the plenary
>>>>
>>>> 1. Patch Submission Process
>>>>
>>>> Today we don't have a uniform patch submission process across
>>>> Storage, Filesystems and MM.A A The question is should we (or at
>>>> least should we adhere to some minimal standards).A A The standard
>>>> we've been trying to hold to in SCSI is one review per accepted
>>>> non-trivial patch.A A For us, it's useful because it encourages
>>>> driver writers to review each other's patches rather than just
>>>> posting and then complaining their patch hasn't gone in.A A I can
>>>> certainly think of a couple of bugs I've had to chase in mm where
>>>> the underlying patches would have benefited from review, so I'd
>>>> like to discuss making the one review per non-trival patch our base
>>>> minimum standard across the whole of LSF/MM; it would certainly
>>>> serve to improve our Reviewed-by statistics.
>>>
>>> Well, the mm track at least has some discussion of this last year:
>>> https://lwn.net/Articles/718212/
>>
>> The pushback in your session was mandating reviews would mean slowing
>> patch acceptance or possibly causing the dropping of patches that
>> couldn't get reviewed. A Michal did say that XFS didn't have the
>> problem, however there not being XFS people in the room, discussion
>> stopped there.
> 
> I actually /was/ lurking in the session, but a year later I have more
> thoughts:
> 
> Now that I've been maintainer for more than a year I feel more confident
> in actually talking about our review processes, though I can only speak
> about my own experiences and hope the other xfs developers chime in if
> they choose.

<everything Darrick says sounds pretty much spot on and more eloquent
than I'm likely to provide, but here goes... >

Mandating reviews certainly can slow down patch acceptance, though I'd
expect that any good maintainer will be doing at least cursory review
before commit; when the maintainer writes patches themselves, they /are/
then at the mercy of others for an RVB: tag.  That hasn't in general
been a huge problem for us, though things do sometimes require a bit of
poking and prodding.  But I think that's a feature not a bug.  Obtaining
at least one meaningful review means that someone else has at least
some familiarity with the new code.

In the XFS community, in reality we have only about 4 kernelspace
reviewers, with a /very/ long tail of onesey-twosies; since v4.12:

<lots of 1's>
      2     Reviewed-by: Allison Henderson <allison.henderson@oracle.com>
      2     Reviewed-by: Eric Sandeen <sandeen@redhat.com>
      3     Reviewed-by: Amir Goldstein <amir73il@gmail.com>
      4     Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
      6     Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
      6     Reviewed-by: Jan Kara <jack@suse.cz>
     10     Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
     60     Reviewed-by: Christoph Hellwig <hch@lst.de>
    104     Reviewed-by: Dave Chinner <dchinner@redhat.com>
    109     Reviewed-by: Brian Foster <bfoster@redhat.com>
    208     Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

In userspace things look a little different in the same time period:

      1     Reviewed-by: Allison Henderson <allison.henderson@oracle.com>
      1     Reviewed-by: Bill O'Donnell <billodo@redhat.com>
      1     Reviewed-by: Eric Sandeen <sandeen@sandeen.net>
      3     Reviewed-by: Dave Chinner <dchinner@redhat.com>
     11     Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
     12     Reviewed-by: Christoph Hellwig <hch@lst.de>
     25     Reviewed-by: Brian Foster <bfoster@redhat.com>
     37     Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
     44     Reviewed-by: Eric Sandeen <sandeen@redhat.com>

Unsurprisingly(?) the maintainers still bear a lot of the review burden, but
the same workhorse rock stars are clearly present.  In reality it's something
we need to work on, to try to get more people participating in meaningful review,
both to speed up the cycle and to grow community knowledge.

Another thing that Darrick and I have bounced around a little bit is
the adequacy of email for significant review of large feature patchsets.
On the one hand, we'd like centralized review with archives, because
that's useful to future code archaeologists.  On the other hand, I can't
help but think that something like Github's ability to mark up 
comments line by line would have some advantages, particularly for
brand new code.



As for the question of conflict, I'm not sure what to say...  The XFS
development team has been lucky(?) to have been living in relative peace
and harmony for the past few years.  Speaking for myself, I try to
be aware of getting too nitpicky or enforcing preferences vs. requirements,
and I make an effort to reach out and check in with patch submitters
to keep things calibrated.  Having the dedicated #xfs channel helps here,
I think, for higher bandwidth communication about issues when needed.
I have no doubt that I've annoyed Darrick or Dave or Brian from time to
time (Dave usually makes this very obvious ;)) but we try to talk to each
other like humans and it seems to work out ok in the long run.

An expectation of 100% review surely helps here as well; if only 20%
of patches get reviewed, the reviews may stick out like criticism.  If
the expectation is that everything is meaningfully reviewed, nobody is
surprised by feedback when it comes.

> I'd show up, so long as this wasn't scheduled against something else.
> (IOWs, yes please.)

As would I (if I'm invited) :)  As xfsprogs maintainer I probably have
some useful insights to our submit/review/commit cycle as well.

Thanks,
-Eric

> --D
> 
>> James
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

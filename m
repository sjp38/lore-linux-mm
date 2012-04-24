Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D791C6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 02:18:44 -0400 (EDT)
Received: by obbeh20 with SMTP id eh20so665085obb.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 23:18:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPa8GCCE7x=ox0K=QoFR8+bTNrUqfFO+ooRKDLNROnd7xsF4Pw@mail.gmail.com>
References: <1334863211-19504-1-git-send-email-tytso@mit.edu>
	<4F912880.70708@panasas.com>
	<alpine.LFD.2.00.1204201120060.27750@dhcp-27-109.brq.redhat.com>
	<1334919662.5879.23.camel@dabdike>
	<alpine.LFD.2.00.1204201313231.27750@dhcp-27-109.brq.redhat.com>
	<1334932928.13001.11.camel@dabdike>
	<20120420145856.GC24486@thunk.org>
	<CAHGf_=oWtpgRfqaZ1YDXgZoQHcFY0=DYVcwXYbFtZt2v+K532w@mail.gmail.com>
	<CAPa8GCDkP_53VGAeQPeYgf3GW3KZ09BvnqduArQE7svf2mMj4A@mail.gmail.com>
	<1335169383.4191.9.camel@dabdike.lan>
	<CAPa8GCCE7x=ox0K=QoFR8+bTNrUqfFO+ooRKDLNROnd7xsF4Pw@mail.gmail.com>
Date: Tue, 24 Apr 2012 16:18:43 +1000
Message-ID: <CAPa8GCAv-E2iAfvwizMsbhEj11Ak6p2MKRyUVSm01LMkrTNZFQ@mail.gmail.com>
Subject: Re: [PATCH, RFC 0/3] Introduce new O_HOT and O_COLD flags
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Ted Ts'o <tytso@mit.edu>, Lukas Czerner <lczerner@redhat.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-mm@kvack.org

On 23 April 2012 21:47, Nick Piggin <npiggin@gmail.com> wrote:
> On 23 April 2012 18:23, James Bottomley

>> Experience has taught me to be wary of fine grained hints: they tend to
>> be more trouble than they're worth (the definitions are either
>> inaccurate or so tediously precise that no-one can be bothered to read
>> them). =A0A small set of broad hints is usually more useable than a huge
>> set of fine grained ones, so from that point of view, I like the
>> O_HOT/O_COLD ones.
>
> So long as the implementations can be sufficiently general that large maj=
ority
> of "reasonable" application of the flags does not result in a slowdown, p=
erhaps.
>
> But while defining the API, you have to think about these things and not
> just dismiss them completely.
>
> Read vs write can be very important for caches and tiers, same for
> random/linear,
> latency constraints, etc. These things aren't exactly a huge unwieldy mat=
rix. We
> already have similar concepts in fadvise and such.

I'm not saying it's necessarily a bad idea as such. But experience
has taught me that if you define an API before having much
experience of the implementation and its users, and without
being able to write meaningful documentation for it, then it's
going to be a bad API.

So rather than pushing through these flags first, I think it would
be better to actually do implementation work, and get some
benchmarks (if not real apps) and have something working
like that before turning anything into an API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

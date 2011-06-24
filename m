Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 274DD900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 09:32:28 -0400 (EDT)
Received: by pvc12 with SMTP id 12so2205258pvc.14
        for <linux-mm@kvack.org>; Fri, 24 Jun 2011 06:32:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110624125131.GQ9396@suse.de>
References: <BANLkTik7ubq9ChR6UEBXOo5D9tn3mMb1Yw@mail.gmail.com>
 <BANLkTikKwbsRD=WszbaUQQMamQbNXFdsPA@mail.gmail.com> <4E0465D8.3080005@draigBrady.com>
 <20110624125131.GQ9396@suse.de>
From: Andrew Lutomirski <luto@mit.edu>
Date: Fri, 24 Jun 2011 09:32:01 -0400
Message-ID: <BANLkTi=YAOTX08E=aPbbU9AcsiYPmiK2Ow@mail.gmail.com>
Subject: Re: Root-causing kswapd spinning on Sandy Bridge laptops?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: P?draig Brady <P@draigbrady.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org

On Fri, Jun 24, 2011 at 8:51 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Fri, Jun 24, 2011 at 11:24:24AM +0100, P?draig Brady wrote:
>> On 24/06/11 10:27, Minchan Kim wrote:
>> > Hi Andrew,
>> >
>> > Sorry but right now I don't have a time to dive into this.
>> > But it seems to be similar to the problem Mel is looking at.
>> > Cced him.
>> >
>> > Even, P=E1draig Brady seem to have a reproducible scenario.
>> > I will look when I have a time.
>> > I hope I will be back sooner or later.
>>
>> My reproducer is (I've 3GB RAM, 1.5G swap):
>> =A0 dd bs=3D1M count=3D3000 if=3D/dev/zero of=3Dspin.test
>>
>> To stop it spinning I just have to uncache the data,
>> the handiest way being:
>> =A0 rm spin.test
>>
>> To confirm, the top of the profile I posted is:
>> =A0 i915_gem_object_bind_to_gtt
>> =A0 =A0 shrink_slab
>>
>
> I don't think it's an i915 bug. Another candidate fix in the other
> thread that Padraig started.

I bet you're right.  I do indeed have a tiny high zone.  (No clue why
-- I have 2G of ram right now.)

I won't be a reliable tester because I don't have a good way to
reproduce this bug.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f54.google.com (mail-vn0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7786B006E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 12:44:08 -0400 (EDT)
Received: by vnbf62 with SMTP id f62so17240427vnb.3
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 09:44:08 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id kp7si3306175oeb.81.2015.04.15.09.44.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 09:44:07 -0700 (PDT)
From: "Norton, Scott J" <scott.norton@hp.com>
Subject: RE: [RFC PATCH 0/14] Parallel memory initialisation
Date: Wed, 15 Apr 2015 16:42:37 +0000
Message-ID: <E2BC6EB51A09EC46A4906DEA4A9496EE1529F1CD@G9W0719.americas.hpqcorp.net>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
 <552E6486.6070705@hp.com>
 <20150415142731.GI17717@twins.programming.kicks-ass.net>
 <20150415143420.GG14842@suse.de>
 <20150415144818.GX5029@twins.programming.kicks-ass.net> <552E8F72.408@hp.com>
In-Reply-To: <552E8F72.408@hp.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Long, Wai Man" <waiman.long@hp.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, "Vaden, Tom (HP
 Server OS Architecture)" <tom.vaden@hp.com>, LKML <linux-kernel@vger.kernel.org>


On 04/15/2015 10:48 AM, Peter Zijlstra wrote:
> On Wed, Apr 15, 2015 at 03:34:20PM +0100, Mel Gorman wrote:
>> On Wed, Apr 15, 2015 at 04:27:31PM +0200, Peter Zijlstra wrote:
>>> On Wed, Apr 15, 2015 at 09:15:50AM -0400, Waiman Long wrote:
>>>> I had included your patch with the 4.0 kernel and booted up a=20
>>>> 16-socket 12-TB machine. I measured the elapsed time from the elilo=20
>>>> prompt to the availability of ssh login. Without the patch, the=20
>>>> bootup time was 404s. It was reduced to 298s with the patch. So=20
>>>> there was about 100s reduction in bootup time (1/4 of the total).
>>> But you cheat! :-)
>>>
>>> How long between power on and the elilo prompt? Do the 100 seconds=20
>>> matter on that time scale?
>>>
>> Calling it cheating is a *bit* harsh as the POST times vary=20
>> considerably between manufacturers. While I'm interested in Waiman's=20
>> answer, I'm told that those that really care about minimising reboot=20
>> times will use kexec to avoid POST.  The 100 seconds is 100 seconds,=20
>> whether that is 25% in all cases is a different matter.
>>
> Sure POST times vary, but its consistently stupid long :-) I'm forever=20
> thinking my EX machine died because its not coming back from a power=20
> cycle, and mine isn't really _that_ large.

Yes, 100 seconds really does matter and is a big deal. When a business has =
one of=20
these large machines go down their business is stopped (unless they have a
fast failover solution in place). Every minute and second the machine is do=
wn=20
is crucial to these businesses.  The fact that POST times can be so long ma=
ke it
even more important that we make the kernel boot as fast as possible.

Scott

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

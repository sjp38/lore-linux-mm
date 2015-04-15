Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 76A146B006E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 12:19:21 -0400 (EDT)
Received: by oift201 with SMTP id t201so30018571oif.3
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 09:19:21 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id zr4si3270874obc.42.2015.04.15.09.19.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 09:19:03 -0700 (PDT)
Message-ID: <552E8F72.408@hp.com>
Date: Wed, 15 Apr 2015 12:18:58 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
References: <1428920226-18147-1-git-send-email-mgorman@suse.de> <552E6486.6070705@hp.com> <20150415142731.GI17717@twins.programming.kicks-ass.net> <20150415143420.GG14842@suse.de> <20150415144818.GX5029@twins.programming.kicks-ass.net>
In-Reply-To: <20150415144818.GX5029@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2015 10:48 AM, Peter Zijlstra wrote:
> On Wed, Apr 15, 2015 at 03:34:20PM +0100, Mel Gorman wrote:
>> On Wed, Apr 15, 2015 at 04:27:31PM +0200, Peter Zijlstra wrote:
>>> On Wed, Apr 15, 2015 at 09:15:50AM -0400, Waiman Long wrote:
>>>> I had included your patch with the 4.0 kernel and booted up a 16-socket
>>>> 12-TB machine. I measured the elapsed time from the elilo prompt to the
>>>> availability of ssh login. Without the patch, the bootup time was 404s. It
>>>> was reduced to 298s with the patch. So there was about 100s reduction in
>>>> bootup time (1/4 of the total).
>>> But you cheat! :-)
>>>
>>> How long between power on and the elilo prompt? Do the 100 seconds
>>> matter on that time scale?
>> Calling it cheating is a *bit* harsh as the POST times vary considerably
>> between manufacturers. While I'm interested in Waiman's answer, I'm told
>> that those that really care about minimising reboot times will use kexec
>> to avoid POST.  The 100 seconds is 100 seconds, whether that is 25% in
>> all cases is a different matter.
> Sure POST times vary, but its consistently stupid long :-) I'm forever
> thinking my EX machine died because its not coming back from a power
> cycle, and mine isn't really _that_ large.

I agree with that. I always complain about the long POST time of those 
server machines.

As for Mel's patch, what I wanted to show is its impact on the OS bootup 
part of the boot process. We have no control on how long the firmware 
POST is, so there is no point in lumping them into the discussion.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

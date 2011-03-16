Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B2A6F8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 11:26:13 -0400 (EDT)
Message-ID: <4D80D65C.5040504@fiec.espol.edu.ec>
Date: Wed, 16 Mar 2011 10:25:16 -0500
From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
 <avillaci@fiec.espol.edu.ec>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
References: <bug-31142-10286@https.bugzilla.kernel.org/>	<20110315135334.36e29414.akpm@linux-foundation.org>	<4D7FEDDC.3020607@fiec.espol.edu.ec> <20110315161926.595bdb65.akpm@linux-foundation.org>
In-Reply-To: <20110315161926.595bdb65.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

El 15/03/11 18:19, Andrew Morton escribio:
> On Tue, 15 Mar 2011 17:53:16 -0500
> Alex Villac____s Lasso<avillaci@fiec.espol.edu.ec>  wrote:
>
>> El 15/03/11 15:53, Andrew Morton escribi__:
>>> rofl, will we ever fix this.
>> Does this mean there is already a duplicate of this issue? If so, which one?
> Nothing specific.  Nonsense like this has been happening for at least a
> decade and it never seems to get a lot better.
>
>>> Please enable sysrq and do a sysrq-w when the tasks are blocked so we
>>> can find where things are getting stuck.  Please avoid email client
>>> wordwrapping when sending us the sysrq output.
>>>
Posted sysrq-w report into original bug report to avoid email word-wrap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE516B0389
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 04:05:57 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id x1so11533617lff.6
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 01:05:57 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id n201si696822lfa.209.2017.02.10.01.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 01:05:55 -0800 (PST)
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
References: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
 <20170209192640.GC31906@dhcp22.suse.cz> <20170209200737.GB11098@kroah.com>
 <20170209205407.GF31906@dhcp22.suse.cz>
 <845d420f-dd26-fb48-c8ef-10ca1995daf8@sonymobile.com>
 <20170210075149.GA17166@kroah.com>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <b6236b07-3fbd-4f58-f7bb-97847ec8ad7f@sonymobile.com>
Date: Fri, 10 Feb 2017 10:05:12 +0100
MIME-Version: 1.0
In-Reply-To: <20170210075149.GA17166@kroah.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, devel@driverdev.osuosl.org, Riley
 Andrews <riandrews@android.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 02/10/2017 08:51 AM, Greg Kroah-Hartman wrote:
> On Fri, Feb 10, 2017 at 08:21:32AM +0100, peter enderborg wrote:
>> Im not speaking for google, but I think there is a work ongoing to
>> replace this with user-space code.
> Really?  I have not heard this at all, any pointers to whom in Google is
> doing it?
>
I think it was mention some of the google conferences. The idea
is the lmkd that uses memory pressure events to trigger this.
>From git log in lmkd i think Colin Cross is involved.

>> Until then we have to polish this version as good as we can. It is
>> essential for android as it is now.
> But if no one is willing to do the work to fix the reported issues, why
> should it remain? 
It is needed by billions of phones.
>  Can you do the work here? 
No. Change the kernel is only one small part of the solution.
>  You're already working on
> fixing some of the issues in a differnt way, why not do the "real work"
> here instead for everyone to benifit from?
The long term solution is something from AOSP.  As you know
we tried to contribute this to AOSP.  As OEM we can't turn android
upside down.  It has to be a step by step.
> thanks,
>
> greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

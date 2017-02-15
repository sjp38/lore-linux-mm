Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 375E7680FD0
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 03:22:20 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id o12so63235637lfg.7
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 00:22:20 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id r2si1537056lfg.192.2017.02.15.00.22.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 00:22:19 -0800 (PST)
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
References: <20170214160932.4988-1-peter.enderborg@sonymobile.com>
 <20170214165102.GE17335@kroah.com>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <ef98ccbf-8e18-e55a-3af3-7ecec5fa60c5@sonymobile.com>
Date: Wed, 15 Feb 2017 09:21:56 +0100
MIME-Version: 1.0
In-Reply-To: <20170214165102.GE17335@kroah.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, arve@android.com, riandrews@android.com, torvalds@linux-foundation.org, linux-mm@kvack.org

On 02/14/2017 05:51 PM, Greg KH wrote:
> On Tue, Feb 14, 2017 at 05:09:30PM +0100, peter.enderborg@sonymobile.com wrote:
>> From: Peter Enderborg <peter.enderborg@sonymobile.com>
>>
>> This collects stats for shrinker calls and how much
>> waste work we do within the lowmemorykiller.
>>
>> Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>
> Wait, what changed from the previous versions of this patch?  Did you
> take the review comments into consideration, or is this just a resend of
> the original patches in a format that isn't corrupted?
>
> thanks,
>
> greg k-h

This is just a send with git-send-email that seems to work better. Nothing
else than tab-spaces should be different. I would like to have some positive
feedback from google/android before I start to send updated patches to the list.
If google are ready for the userspace solution this patch set is pointless for
upstream kernel.

Michal Hocko is very negative to hole thing, but we have addressed at least some
issues he pointed out on the list in 2015. Is there any idea to continue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

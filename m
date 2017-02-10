Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 007DF6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 02:12:31 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id x1so10526713lff.6
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 23:12:30 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id 28si515541lfr.419.2017.02.09.23.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 23:12:29 -0800 (PST)
Subject: Re: [PATCH 1/3 v2 staging-next] android: Collect statistics from
 lowmemorykiller
References: <df828d70-3962-2e43-0512-1777a9842bb2@sonymobile.com>
 <e3dc46d0-7431-c97c-d8cf-824f30706175@sonymobile.com>
 <20170209201329.GA12148@kroah.com>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <90fbd714-df4d-8c91-b2cc-927492b6c838@sonymobile.com>
Date: Fri, 10 Feb 2017 08:12:28 +0100
MIME-Version: 1.0
In-Reply-To: <20170209201329.GA12148@kroah.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On 02/09/2017 09:13 PM, Greg Kroah-Hartman wrote:
> On Thu, Feb 09, 2017 at 04:42:35PM +0100, peter enderborg wrote:
>> This collects stats for shrinker calls and how much
>> waste work we do within the lowmemorykiller.
>>
>> Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>
>> ---
>>  drivers/staging/android/Kconfig                 | 11 ++++
>>  drivers/staging/android/Makefile                |  1 +
>>  drivers/staging/android/lowmemorykiller.c       |  9 ++-
>>  drivers/staging/android/lowmemorykiller_stats.c | 85 +++++++++++++++++++++++++
>>  drivers/staging/android/lowmemorykiller_stats.h | 29 +++++++++
>>  5 files changed, 134 insertions(+), 1 deletion(-)
>>  create mode 100644 drivers/staging/android/lowmemorykiller_stats.c
>>  create mode 100644 drivers/staging/android/lowmemorykiller_stats.h
> What changed from v1?
Nothing. I thought I found the reason why my tabs are replaced by spaces in transport.

>> @@ -72,6 +73,7 @@ static unsigned long lowmem_deathpending_timeout;
>>  static unsigned long lowmem_count(struct shrinker *s,
>>                    struct shrink_control *sc)
>>  {
>> +    lmk_inc_stats(LMK_COUNT);
>>      return global_node_page_state(NR_ACTIVE_ANON) +
>>          global_node_page_state(NR_ACTIVE_FILE) +
>>          global_node_page_state(NR_INACTIVE_ANON) +
> Your email client is eating tabs and spitting out spaces, making this
> impossible to even consider being merged :(
>
> Please fix your email client, documentation for how to do so is in the
> kernel Documentation directory.
>
> thanks,
>
> greg k-h


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

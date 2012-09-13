Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 824176B0117
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 20:30:56 -0400 (EDT)
Received: by iec9 with SMTP id 9so4968672iec.14
        for <linux-mm@kvack.org>; Wed, 12 Sep 2012 17:30:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1209091424580.13346@chino.kir.corp.google.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209091424580.13346@chino.kir.corp.google.com>
Date: Wed, 12 Sep 2012 21:30:55 -0300
Message-ID: <CALF0-+WiEz40qbVbCskuc3TfRcMQUr7wJA20_FfnQmGctG3FXQ@mail.gmail.com>
Subject: Re: [PATCH 01/10] Makefile: Add option CONFIG_DISABLE_GCC_AUTOMATIC_INLINING
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, sam@ravnborg.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Marek <mmarek@suse.cz>

Hi,

On Sun, Sep 9, 2012 at 6:25 PM, David Rientjes <rientjes@google.com> wrote:
> On Sat, 8 Sep 2012, Ezequiel Garcia wrote:
>
>> diff --git a/Makefile b/Makefile
>> index ddf5be9..df6045a 100644
>> --- a/Makefile
>> +++ b/Makefile
>> @@ -561,6 +561,10 @@ else
>>  KBUILD_CFLAGS        += -O2
>>  endif
>>
>> +ifdef CONFIG_DISABLE_GCC_AUTOMATIC_INLINING
>> +KBUILD_CFLAGS        += -fno-inline-small-functions
>
> This isn't the only option that controls automatic inlining of functions,
> see indirect-inlining, inline-functions, and inline-functions-called-once.
>

I'll check about this gcc options and re-send, renamed as:
CONFIG_DISABLE_CC_AUTOMATIC_INLINING

Thanks for both your feedback,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

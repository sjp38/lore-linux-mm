Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E06816B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 02:39:44 -0400 (EDT)
Message-ID: <4DDDF5A9.8060906@kpanic.de>
Date: Thu, 26 May 2011 08:39:37 +0200
From: Stefan Assmann <sassmann@kpanic.de>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] Add documentation and credits for BadRAM
References: <1306236048-18150-1-git-send-email-sassmann@kpanic.de>	<1306236048-18150-4-git-send-email-sassmann@kpanic.de> <20110524165543.3c31d9ea.rdunlap@xenotime.net>
In-Reply-To: <20110524165543.3c31d9ea.rdunlap@xenotime.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: linux-mm@kvack.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, akpm@linux-foundation.org

On 25.05.2011 01:55, Randy Dunlap wrote:
> On Tue, 24 May 2011 13:20:48 +0200 Stefan Assmann wrote:
>> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
>> index cc85a92..ba3e984 100644
>> --- a/Documentation/kernel-parameters.txt
>> +++ b/Documentation/kernel-parameters.txt
>> @@ -51,6 +51,7 @@ parameter is applicable:
>>  	FB	The frame buffer device is enabled.
>>  	GCOV	GCOV profiling is enabled.
>>  	HW	Appropriate hardware is enabled.
>> +	HWPOISON Handling of memory pages reported as being corrupt
> 
> These entries are normally used as in my example below.  I'm not sure that
> it makes sense here.
> 
>>  	IA-64	IA-64 architecture is enabled.
>>  	IMA     Integrity measurement architecture is enabled.
>>  	IOSCHED	More than one I/O scheduler is enabled.
>> @@ -373,6 +374,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>>  
>>  	autotest	[IA64]
>>  
>> +	badram=		When CONFIG_MEMORY_FAILURE is set, this parameter
> 
>         badram=		[HWPOISON] When CONFIG_MEMORY_FAILURE is set, this parameter

New patch with spelling fixes and updated
Documentation/kernel-parameters.txt.
Thanks Randy.

  Stefan

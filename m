Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B20C34402F0
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 13:13:49 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so128543910pac.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 10:13:49 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id n12si2716906pfa.89.2015.12.07.10.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 10:13:48 -0800 (PST)
Received: by pacej9 with SMTP id ej9so128732718pac.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 10:13:48 -0800 (PST)
Subject: Re: [linux-next:master 4174/4356] kernel/built-in.o:undefined
 reference to `mmap_rnd_bits'
References: <201512050045.l2G9WhTi%fengguang.wu@intel.com>
 <20151204151424.e73641da44c61f20f10d93e9@linux-foundation.org>
 <20151204151913.166e5cb795359ff1a53d26ac@linux-foundation.org>
 <CAJQetW4L6Zuzd9GENK6XMg+OVtFUjyE4jOzoG+VB3HtwmoUmiA@mail.gmail.com>
 <20151204170113.c5cd8a9cc9658c491851bc33@linux-foundation.org>
 <CAJQetW54FNRKd5LtpkAk0P_bPyAZi6iKnZhEhz1n9oSOm-Wc9Q@mail.gmail.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <5665CC5A.7030407@android.com>
Date: Mon, 7 Dec 2015 10:13:46 -0800
MIME-Version: 1.0
In-Reply-To: <CAJQetW54FNRKd5LtpkAk0P_bPyAZi6iKnZhEhz1n9oSOm-Wc9Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Mark Brown <broonie@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 12/04/2015 05:46 PM, Daniel Cashman wrote:
>>> Please let me know what else should be done in v6 to keep these in.
>>
>> It sounds like all we need to do at present is to fix this build error?
> 
> My apologies, I thought this was the one related to CONFIG_MMU=n.
> I've reproduced locally and will look into this on Monday.
> 

Actually, I just cloned linux-next and am not seeing this when
cross-compiling arm with the provided config unless "if MMU" is removed.
 So perhaps it was the same error and my local state was strange?

At present, I plan to prepare v6 to make some minor arm64 Kconfig
changes and corrects the ifdef missing character.

Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

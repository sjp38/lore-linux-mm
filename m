Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D36B228026B
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 21:54:35 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu14so331437576pad.0
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 18:54:35 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id yp5si7354348pac.42.2016.09.25.18.54.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Sep 2016 18:54:35 -0700 (PDT)
Date: Mon, 26 Sep 2016 09:54:29 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: undefined reference to `printk'
Message-ID: <20160926015429.z5czauf5c5imnkse@wfg-t540p.sh.intel.com>
References: <201609251139.vxagmOPP%fengguang.wu@intel.com>
 <1474775186.23838.23.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1474775186.23838.23.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Joe,

On Sat, Sep 24, 2016 at 08:46:26PM -0700, Joe Perches wrote:
>On Sun, 2016-09-25 at 11:40 +0800, kbuild test robot wrote:
>> Hi Joe,
>
>Hey Fengguang
>
>> It's probably a bug fix that unveils the link errors.
>
>I think all of these reports about compiler-gcc integrations
>are bogons.

Yes, sorry for the noises again!

>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> head:   9c0e28a7be656d737fb18998e2dcb0b8ce595643
>> commit: cb984d101b30eb7478d32df56a0023e4603cba7f compiler-gcc: integrate the various compiler-gcc[345].h files

It looks there are different commit SHA1 in different trees for that patch.
I'll match it by patch subject rather than commit id.

Cheers,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

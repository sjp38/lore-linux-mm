Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A24176B0038
	for <linux-mm@kvack.org>; Sun, 11 Sep 2016 19:44:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x24so324117975pfa.0
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 16:44:42 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id bl7si18264646pad.14.2016.09.11.16.44.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Sep 2016 16:44:41 -0700 (PDT)
Date: Mon, 12 Sep 2016 07:44:37 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [linux-stable-rc:linux-3.14.y 1941/4977]
 include/linux/irqdesc.h:80:33: error: 'NR_IRQS' undeclared here (not in a
 function)
Message-ID: <20160911234437.voyzdbxvvd2w5oqk@wfg-t540p.sh.intel.com>
References: <201609120447.p6I9GrZF%fengguang.wu@intel.com>
 <20160911204731.GB30805@sasha-lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20160911204731.GB30805@sasha-lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Levin, Alexander" <alexander.levin@verizon.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Sasha,

On Sun, Sep 11, 2016 at 04:47:31PM -0400, Levin, Alexander wrote:
>On Sun, Sep 11, 2016 at 04:06:50PM -0400, kbuild test robot wrote:
>> Hi Sasha,
>>
>> FYI, the error/warning still remains.
>>
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-3.14.y
>> head:   b65f2f457c49b2cfd7967c34b7a0b04c25587f13
>> commit: 017ff97daa4a7892181a4dd315c657108419da0c [1941/4977] kernel: add support for gcc 5
>
>Please make it stop :(
>
>I've introduced a commit to support gcc 5, and I'm guessing that in turn your build system now probably builds using gcc 5 for anything past that point, right?

Yes, many "hidden" error/warnings show up after that commit. I'll
ignore bisects to this commit.

>This causes new errors/warnings which appear to be caused by my commit, but obviously aren't.
>
>Can you please make the build system just ignore this commit if it gets bisected?

Yes, sure. Sorry for the noises!

Cheers,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 383956B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 12:07:55 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so4254667pdi.21
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 09:07:54 -0800 (PST)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id yp10si8902532pab.98.2014.03.07.09.07.47
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 09:07:47 -0800 (PST)
Date: Fri, 7 Mar 2014 11:07:45 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [next:master 452/458] undefined reference to
 `__bad_size_call_parameter'
In-Reply-To: <20140306131835.543007307bf38e8986f1229c@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1403071106280.21846@nuc>
References: <53188aab.D8+W+0kHpmaV0uFd%fengguang.wu@intel.com> <20140306131835.543007307bf38e8986f1229c@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Thu, 6 Mar 2014, Andrew Morton wrote:

> On Thu, 06 Mar 2014 22:48:11 +0800 kbuild test robot
> <fengguang.wu@intel.com> wrote:
> This has me stumped - the same code
>
> 	p = __this_cpu_read(current_kprobe);
>
> works OK elsewhere in that file.  I'm suspecting a miscompile - it's
> not unknown for gcc to screw up when we use this trick.
>
> I can reproduce it with gcc-3.4.5 for sh.

This is again the autoconversion not applying because current_kprobe is
probably a pointer. __bad_size_call_parameter is failure because reads
from structures larger than word size are not supported.

p = this_cpu_ptr(&current_kprobe);

would fix it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

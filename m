Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34CB86B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 19:43:36 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id j23so3063206qtn.23
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 16:43:36 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l41si7330372qtk.460.2018.03.07.16.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 16:43:35 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w280cwx7033227
	for <linux-mm@kvack.org>; Wed, 7 Mar 2018 19:43:34 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gjtc18yuk-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Mar 2018 19:43:34 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 8 Mar 2018 00:43:32 -0000
Date: Wed, 7 Mar 2018 16:43:24 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [bug?] Access was denied by memory protection keys in
 execute-only address
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
Message-Id: <20180308004324.GK1060@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: mpe@ellerman.id.au, Jan Stancek <jstancek@redhat.com>, ltp@lists.linux.it, linux-mm@kvack.org

On Wed, Mar 07, 2018 at 04:09:06PM +0800, Li Wang wrote:
>    Hi,
> 
>    ltp/mprotect04[1] crashed by SEGV_PKUERR on ppc64(LPAR on P730, Power 8
>    8247-22L) with kernel-v4.16.0-rc4.
>    10000000-10020000 r-xp 00000000 fd:00 167223A A A A A A A A A A  mprotect04
>    10020000-10030000 r--p 00010000 fd:00 167223A A A A A A A A A A  mprotect04
>    10030000-10040000 rw-p 00020000 fd:00 167223A A A A A A A A A A  mprotect04
>    1001a380000-1001a3b0000 rw-p 00000000 00:00 0A A A A A A A A A  [heap]
>    7fffa6c60000-7fffa6c80000 --xp 00000000 00:00 0 a??
>    a??&exec_func = 0x10030170a??
>    a??&func = 0x7fffa6c60170a??
> 
>    a??While perform a??"(*func)();" we get the
>    a??segmentation fault.
>    a??
>    a??strace log:a??
>    -------------------
>    a??mprotect(0x7fffaed00000, 131072, PROT_EXEC) = 0
>    rt_sigprocmask(SIG_BLOCK, NULL, [], 8) A = 0
>    --- SIGSEGV {si_signo=SIGSEGV, si_code=SEGV_PKUERR,
>    si_addr=0x7fffaed00170} ---a??

Ran the same test on my machine. and did not encounter the bug.

Can I get your kernel .config ?
also is this a P7 LPAR or a P8 LPAR?  cat /proc/cpuinfo will help.

Thanks,
RP

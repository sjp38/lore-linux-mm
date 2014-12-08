Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9DBB16B0038
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 16:03:48 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id y20so5335316ier.14
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 13:03:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l8si26423795icm.7.2014.12.08.13.03.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Dec 2014 13:03:46 -0800 (PST)
Date: Mon, 8 Dec 2014 13:03:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 10653/11539] arch/x86/ia32/audit.c:38:14: sparse:
 incompatible types for 'case' statement
Message-Id: <20141208130344.9dc58fda1862a4a4a14c7c6b@linux-foundation.org>
In-Reply-To: <201412090206.Nd6JUQcF%fengguang.wu@intel.com>
References: <201412090206.Nd6JUQcF%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: David Drysdale <drysdale@google.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 9 Dec 2014 02:40:09 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   cf12164be498180dc466ef97194ca7755ea39f3b
> commit: b4baa9e36be0651f7eb15077af5e0eff53b7691b [10653/11539] x86: hook up execveat system call
> reproduce:
>   # apt-get install sparse
>   git checkout b4baa9e36be0651f7eb15077af5e0eff53b7691b
>   make ARCH=x86_64 allmodconfig
>   make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
>    arch/x86/ia32/audit.c:38:14: sparse: undefined identifier '__NR_execveat'
> >> arch/x86/ia32/audit.c:38:14: sparse: incompatible types for 'case' statement
>    arch/x86/ia32/audit.c:38:14: sparse: Expected constant expression in case statement
>    arch/x86/ia32/audit.c: In function 'ia32_classify_syscall':
>    arch/x86/ia32/audit.c:38:7: error: '__NR_execveat' undeclared (first use in this function)
>      case __NR_execveat:
>           ^
>    arch/x86/ia32/audit.c:38:7: note: each undeclared identifier is reported only once for each function it appears in
> --

Confused. This makes no sense and I can't reproduce it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

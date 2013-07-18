Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 765996B0034
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 17:39:30 -0400 (EDT)
Date: Thu, 18 Jul 2013 14:39:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: negative left shift count when PAGE_SHIFT > 20
Message-Id: <20130718143928.4f9b45807956e2fdb1ee3a22@linux-foundation.org>
In-Reply-To: <1374166572-7988-1-git-send-email-uulinux@gmail.com>
References: <1374166572-7988-1-git-send-email-uulinux@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerry <uulinux@gmail.com>
Cc: zhuwei.lu@archermind.com, tianfu.huang@archermind.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 19 Jul 2013 00:56:12 +0800 Jerry <uulinux@gmail.com> wrote:

> When PAGE_SHIFT > 20, the result of "20 - PAGE_SHIFT" is negative. The
> calculating here will generate an unexpected result. In addition, if
> PAGE_SHIFT > 20, The memory size represented by numentries was already
> integral multiple of 1MB.
> 

If you tell me that you have a machine which has PAGE_SIZE=2MB and this
was the only problem which prevented Linux from running on that machine
then I'll apply the patch ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

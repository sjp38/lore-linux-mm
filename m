Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id EDD906B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 16:59:22 -0400 (EDT)
Message-ID: <51EEEE9F.2060600@sr71.net>
Date: Tue, 23 Jul 2013 13:59:11 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>  <20130722083721.GC25976@gmail.com>  <1374513120.16322.21.camel@misato.fc.hp.com>  <20130723080101.GB15255@gmail.com> <1374612301.16322.136.camel@misato.fc.hp.com>
In-Reply-To: <1374612301.16322.136.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, kosaki.motohiro@gmail.com, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On 07/23/2013 01:45 PM, Toshi Kani wrote:
> Dave, is this how you are testing?  Do you always specify a valid memory
> address for your testing?

For the moment, yes.

I'm actually working on some other patches that add the kernel metadata
for memory ranges even if they're not backed by physical memory.  But
_that_ is just for testing and I'll just have to modify whatever you do
here in those patches anyway.

It sounds like you're pretty confident that it has no users, so why
don't you just go ahead and axe it on x86 and config it out completely?
 Folks that need it can just hack it back in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

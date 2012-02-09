Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 9970C6B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 09:06:48 -0500 (EST)
Message-ID: <4F33D2F1.5000606@redhat.com>
Date: Thu, 09 Feb 2012 09:06:41 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: swap storm since kernel 3.2.x
References: <201202041109.53003.toralf.foerster@gmx.de> <201202051107.26634.toralf.foerster@gmx.de> <CAJd=RBCvvVgWqfSkoEaWVG=2mwKhyXarDOthHt9uwOb2fuDE9g@mail.gmail.com> <201202080956.18727.toralf.foerster@gmx.de> <20120208115244.GA24959@sig21.net> <CAJd=RBDbYA4xZRikGtHJvKESdiSE-B4OucZ6vQ+tHCi+hG2+aw@mail.gmail.com> <20120209113606.GA8054@sig21.net> <CAJd=RBDzUpUgZLVU+WSfb8grzMAbi3fcyyZkpX8qpaxu6zYe1g@mail.gmail.com> <20120209132155.GA15147@sig21.net> <20120209135407.GA15492@sig21.net>
In-Reply-To: <20120209135407.GA15492@sig21.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Stezenbach <js@sig21.net>
Cc: Hillf Danton <dhillf@gmail.com>, =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/09/2012 08:54 AM, Johannes Stezenbach wrote:
> On Thu, Feb 09, 2012 at 02:21:55PM +0100, Johannes Stezenbach wrote:
>> it looks good.  Neither do I get the huge debug_objects_cache
>> nor does it swap, after running a crosstool-ng toolchain build.
>> Well, last time I also had one kvm -m 1G instance running.  I'll
>> try if that triggers the issue.  So far:
>
> The kvm produced a bunch of page allocation failures
> on the host:

> (repeats a few times)
>
> I guess that is expected with your patch?

That is indeed why my patch series was significantly larger
than Hillf's little test patch :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 23CD16B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 19:45:11 -0400 (EDT)
Date: Wed, 14 Aug 2013 16:45:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/hotplug: Verify hotplug memory range
Message-Id: <20130814164508.e62614c436df5eabfd504c8c@linux-foundation.org>
In-Reply-To: <1376523242.10300.403.camel@misato.fc.hp.com>
References: <1376162252-26074-1-git-send-email-toshi.kani@hp.com>
	<20130814150901.cd430738912a893d74769e1b@linux-foundation.org>
	<1376523242.10300.403.camel@misato.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, dave@sr71.net, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Wed, 14 Aug 2013 17:34:02 -0600 Toshi Kani <toshi.kani@hp.com> wrote:

> > Printing a u64 is problematic.  Here you assume that u64 is implemented
> > as unsigned long long.  But it can be implemented as unsigned long, by
> > architectures which use include/asm-generic/int-l64.h.  Such an
> > architecture will generate a compile warning here, but I can't
> > immediately find a Kconfig combination which will make that happen.
> 
> Oh, I see.  Should I add the casting below and resend it to you?
> 
>                 (unsigned long long)start, (unsigned long long)size);

I was going to leave it as-is and see if anyone else can find a way of
triggering the warning.  But other sites in mm/memory_hotplug.c have
the casts so I went ahead and fixed it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

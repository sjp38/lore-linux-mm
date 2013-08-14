Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id D2D9A6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 19:47:04 -0400 (EDT)
Message-ID: <1376523946.10300.404.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2] mm/hotplug: Verify hotplug memory range
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 14 Aug 2013 17:45:46 -0600
In-Reply-To: <20130814164508.e62614c436df5eabfd504c8c@linux-foundation.org>
References: <1376162252-26074-1-git-send-email-toshi.kani@hp.com>
	 <20130814150901.cd430738912a893d74769e1b@linux-foundation.org>
	 <1376523242.10300.403.camel@misato.fc.hp.com>
	 <20130814164508.e62614c436df5eabfd504c8c@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, dave@sr71.net, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Wed, 2013-08-14 at 16:45 -0700, Andrew Morton wrote:
> On Wed, 14 Aug 2013 17:34:02 -0600 Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > > Printing a u64 is problematic.  Here you assume that u64 is implemented
> > > as unsigned long long.  But it can be implemented as unsigned long, by
> > > architectures which use include/asm-generic/int-l64.h.  Such an
> > > architecture will generate a compile warning here, but I can't
> > > immediately find a Kconfig combination which will make that happen.
> > 
> > Oh, I see.  Should I add the casting below and resend it to you?
> > 
> >                 (unsigned long long)start, (unsigned long long)size);
> 
> I was going to leave it as-is and see if anyone else can find a way of
> triggering the warning.  But other sites in mm/memory_hotplug.c have
> the casts so I went ahead and fixed it.

Thanks!
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

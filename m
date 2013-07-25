Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 8B0566B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 18:37:01 -0400 (EDT)
Message-ID: <1374791763.16322.237.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 25 Jul 2013 16:36:03 -0600
In-Reply-To: <20130725213822.GG18254@gmail.com>
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>
	 <20130722083721.GC25976@gmail.com>
	 <1374513120.16322.21.camel@misato.fc.hp.com>
	 <20130723080101.GB15255@gmail.com>
	 <1374612301.16322.136.camel@misato.fc.hp.com>
	 <20130724042041.GA8504@gmail.com>
	 <1374685121.16322.218.camel@misato.fc.hp.com>
	 <20130725213822.GG18254@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, dave@sr71.net, kosaki.motohiro@gmail.com, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Thu, 2013-07-25 at 23:38 +0200, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > > You claimed that the only purpose of this on x86 was 
> > > that testing was done on non-hotplug systems, using 
> > > this interface. Non-hotplug systems have e820 maps.
> > 
> > Right.  Sorry, I first thought that the interface needed 
> > to work as defined, i.e. detect a new memory.  But for 
> > the test purpose on non-hotplug systems, that is not 
> > necessary.  So, I agree that we can check e820.
> > 
> > I summarized two options in the email below.
> > https://lkml.org/lkml/2013/7/23/602
> > 
> > Option 1) adds a check with e820.  Option 2) deprecates 
> > the interface by removing the config option from x86 
> > Kconfig.  I was thinking that we could evaluate two 
> > options after this patch gets in.  Does it make sense?
> 
> Yeah.
> 
> That having said, if the e820 check is too difficult to 
> pull off straight away, I also don't mind keeping it as-is 
> if it's useful for testing. Just make sure you document it 
> as "you need to be careful with this" (beyond it being a 
> root-only interface to begin with).

Sounds good.  I will keep it as-is for now, and add more clarification
to the document.  I will send an updated patch shortly.

I will make sure to come back after this patch gets in and we get more
info about users.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

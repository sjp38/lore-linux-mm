Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 6D9976B0032
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 15:35:55 -0400 (EDT)
Message-ID: <1374262502.24916.177.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 19 Jul 2013 13:35:02 -0600
In-Reply-To: <51E993D5.2080409@gmail.com>
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>
	 <51E993D5.2080409@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, dave@sr71.net, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Fri, 2013-07-19 at 15:30 -0400, KOSAKI Motohiro wrote:
> > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > index b32ebf9..408ef68 100644
> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -1344,8 +1344,13 @@ config ARCH_SELECT_MEMORY_MODEL
> >   	depends on ARCH_SPARSEMEM_ENABLE
> >   
> >   config ARCH_MEMORY_PROBE
> > -	def_bool y
> > +	bool "Enable sysfs memory/probe interface"
> > +	default n
> >   	depends on X86_64 && MEMORY_HOTPLUG
> > +	help
> > +	  This option enables a sysfs memory/probe interface for testing.
> > +	  See Documentation/memory-hotplug.txt for more information.
> > +	  If you are unsure how to answer this question, answer N.
> 
> makes sense.
> 
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Great!  Thanks Motohiro!
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

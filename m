Message-ID: <48752EB2.8050406@acm.org>
Date: Wed, 09 Jul 2008 15:33:38 -0600
From: Zan Lynx <zlynx@acm.org>
MIME-Version: 1.0
Subject: Re: 2.6.26-rc8-mm1 - Missing AC97 power save Kconfig?
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
In-Reply-To: <20080703020236.adaa51fa.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc8/2.6.26-rc8-mm1/
> 
> - Seems to work on my x86 test boxes.  It does emit a
>   sleeping-while-atomic warning during exit from an application which
>   holds mlocks.  Known problem.
> 
> - It's dead as a doornail on the powerpc Mac g5.  I'll bisect it later.
[cut]

I don't know if this is well known, or why no one else noticed if it
isn't, but the AC97 power-save Kconfig option CONFIG_SND_AC97_POWER_SAVE
isn't in any of the Kconfig files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

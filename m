Subject: Re: 2.6.0-test3-mm3
From: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
In-Reply-To: <20030819013834.1fa487dc.akpm@osdl.org>
References: <20030819013834.1fa487dc.akpm@osdl.org>
Content-Type: text/plain; charset=iso-8859-1
Message-Id: <1061299520.472.5.camel@lorien>
Mime-Version: 1.0
Date: Tue, 19 Aug 2003 10:25:24 -0300
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

Em Ter, 2003-08-19 as 05:38, Andrew Morton escreveu:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test3/2.6.0-test3-mm3/

While compiling with gcc-3.2:

arch/i386/kernel/dmi_scan.c:167: warning: `dmi_dump_system'
defined but not used

 This warning happens because the only call to
dmi_dump_system() happens when CONFIG_ACPI_BOOT is defined,
but I _not_ have ACPI options enabled.

I'm getting the some warning in bk tree.

thanks,

-- 
Luiz Fernando N. Capitulino

<lcapitulino@prefeitura.sp.gov.br>
<http://www.telecentros.sp.gov.br>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

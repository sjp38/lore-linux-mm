From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.69-mm5
Date: Wed, 14 May 2003 08:33:10 -0400
References: <20030514012947.46b011ff.akpm@digeo.com>
In-Reply-To: <20030514012947.46b011ff.akpm@digeo.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200305140833.10942.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On May 14, 2003 04:29 am, Andrew Morton wrote:
> Various fixes.  It should even compile on uniprocessor.

OK.  It does compile.  There are a few module  problems though:

if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.5.69-mm5; fi
WARNING: /lib/modules/2.5.69-mm5/kernel/sound/isa/snd-es18xx.ko needs unknown symbol isapnp_protocol
WARNING: /lib/modules/2.5.69-mm5/kernel/arch/i386/kernel/suspend.ko needs unknown symbol enable_sep_cpu
WARNING: /lib/modules/2.5.69-mm5/kernel/arch/i386/kernel/suspend.ko needs unknown symbol default_ldt
WARNING: /lib/modules/2.5.69-mm5/kernel/arch/i386/kernel/suspend.ko needs unknown symbol init_tss
WARNING: /lib/modules/2.5.69-mm5/kernel/arch/i386/kernel/apm.ko needs unknown symbol save_processor_state
WARNING: /lib/modules/2.5.69-mm5/kernel/arch/i386/kernel/apm.ko needs unknown symbol restore_processor_state

The snd-es18xx.ko problem has existed in 69-bk for a while (I do not understand why this one happens - 
can some look at it and educate me?  Please).  The rest are new with mm5.  I have not built a recient bk to 
if they are local to mm.

Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Thu, 10 Jul 2003 00:18:53 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.5.74-mm3 - apm_save_cpus() Macro still bombs out
Message-Id: <20030710001853.5a3597b7.akpm@osdl.org>
In-Reply-To: <20030710071035.GR15452@holomorphy.com>
References: <20030708223548.791247f5.akpm@osdl.org>
	<200307091106.00781.schlicht@uni-mannheim.de>
	<20030709021849.31eb3aec.akpm@osdl.org>
	<1057815890.22772.19.camel@www.piet.net>
	<20030710060841.GQ15452@holomorphy.com>
	<20030710071035.GR15452@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: piet@www.piet.net, schlicht@uni-mannheim.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
>  -#define apm_save_cpus()	0
>  +#define apm_save_cpus()	({ cpumask_t __mask__ = CPU_MASK_NONE; __mask__; })

Taking a look at what the APM code is actually doing, I think using
current->cpus_allowed just more sense in here.

Not that it matters at all.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

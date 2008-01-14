Date: Mon, 14 Jan 2008 19:25:31 +0100 (CET)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH 06/10] x86: Change NR_CPUS arrays in topology
In-Reply-To: <20080113183454.815670000@sgi.com>
Message-ID: <Pine.LNX.4.64.0801141925070.24893@fbirervta.pbzchgretzou.qr>
References: <20080113183453.973425000@sgi.com> <20080113183454.815670000@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Jan 13 2008 10:34, travis@sgi.com wrote:
>+++ b/include/asm-x86/cpu.h
>@@ -7,7 +7,7 @@
> #include <linux/nodemask.h>
> #include <linux/percpu.h>
> 
>-struct i386_cpu {
>+struct x86_cpu {
> 	struct cpu cpu;
> };
> extern int arch_register_cpu(int num);

Is not struct x86_cpu kinda redundant here if it only wraps around
one member?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

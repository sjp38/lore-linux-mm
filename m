Message-ID: <478BB336.5000004@sgi.com>
Date: Mon, 14 Jan 2008 11:08:38 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/10] x86: Change NR_CPUS arrays in topology
References: <20080113183453.973425000@sgi.com> <20080113183454.815670000@sgi.com> <Pine.LNX.4.64.0801141925070.24893@fbirervta.pbzchgretzou.qr>
In-Reply-To: <Pine.LNX.4.64.0801141925070.24893@fbirervta.pbzchgretzou.qr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jan Engelhardt wrote:
> On Jan 13 2008 10:34, travis@sgi.com wrote:
>> +++ b/include/asm-x86/cpu.h
>> @@ -7,7 +7,7 @@
>> #include <linux/nodemask.h>
>> #include <linux/percpu.h>
>>
>> -struct i386_cpu {
>> +struct x86_cpu {
>> 	struct cpu cpu;
>> };
>> extern int arch_register_cpu(int num);
> 
> Is not struct x86_cpu kinda redundant here if it only wraps around
> one member?

Looking at it, I think the x86 arch specific include file
is including the generic struct cpu (instead of say, a
different one)...?

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

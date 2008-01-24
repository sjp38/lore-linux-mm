Message-ID: <4798BBD6.1020704@sgi.com>
Date: Thu, 24 Jan 2008 08:24:54 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: add percpu, cpu_to_node debug options
References: <20080122230409.198261000@sgi.com> <20080122230409.514557000@sgi.com> <20080124155938.GC4857@elte.hu>
In-Reply-To: <20080124155938.GC4857@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * travis@sgi.com <travis@sgi.com> wrote:
> 
>> +config THREAD_ORDER
>> +	int "Kernel stack size (in page order)"
>> +	range 1 3
>> +	depends on X86_64
>> +	default "3" if X86_SMP
>> +	default "1"
>> +	help
>> +	  Increases kernel stack size.
> 
> you keep sending this broken portion, please dont ... 
> 
> 	Ingo

Sorry, I noted in the comments that that's only for the DEBUG patch, and
you shouldn't apply that, except when attempting to up the NR_CPUS count
for testing.  (I should perhaps just quit submitting it? ;-)

As a side note, soon we should be able to up NR_CPUS and not worry about
stack overflows.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

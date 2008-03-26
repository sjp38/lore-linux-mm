Message-ID: <47EA87D8.8030305@zytor.com>
Date: Wed, 26 Mar 2008 10:28:56 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/10] x86: reduce memory and stack usage in	intel_cacheinfo
References: <20080325220650.835342000@polaris-admin.engr.sgi.com> <20080325220651.683748000@polaris-admin.engr.sgi.com> <20080326065023.GG18301@elte.hu> <47EA6EA3.1070609@sgi.com> <20080326171241.GC20016@elte.hu>
In-Reply-To: <20080326171241.GC20016@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Mike Travis <travis@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
>> The main goal was to avoid allocating 4096 bytes when only 32 would do 
>> (characters needed to represent nr_cpu_ids cpus instead of NR_CPUS 
>> cpus.) But I'll look at cleaning it up a bit more.  It wouldn't have 
>> to be a function if CHUNKSZ in cpumask_scnprintf() were visible (or a 
>> non-changeable constant.)
> 
> well, do we care about allocating 4096 bytes, as long as we also free 
> it? It's not like we need to clear all the bytes or something. Am i 
> missing something here?

Well, 32 bytes fits on the stack, whereas 4096 bytes requires allocating 
a page -- which means either taking the risk of failing or blocking.  Of 
course, we're doing this for output, which has the same issue.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

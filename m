Message-ID: <47A81513.4010301@cosmosbay.com>
Date: Tue, 05 Feb 2008 08:49:39 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: SLUB: Support for statistics to help analyze allocator behavior
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0802050923220.14675@sbz-30.cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.64.0802050923220.14675@sbz-30.cs.Helsinki.FI>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka J Enberg a ecrit :
> Hi Christoph,
> 
> On Mon, 4 Feb 2008, Christoph Lameter wrote:
>> The statistics provided here allow the monitoring of allocator behavior
>> at the cost of some (minimal) loss of performance. Counters are placed in
>> SLUB's per cpu data structure that is already written to by other code.
> 
> Looks good but I am wondering if we want to make the statistics per-CPU so 
> that we can see the kmalloc/kfree ping-pong of, for example, hackbench 
> better?

AFAIK Christoph patch already have percpu statistics :)


+#define STAT_ATTR(si, text) 					\
+static ssize_t text##_show(struct kmem_cache *s, char *buf)	\
+{								\
+	unsigned long sum  = 0;					\
+	int cpu;						\
+								\
+	for_each_online_cpu(cpu)				\
+		sum += get_cpu_slab(s, cpu)->stat[si];		\
+	return sprintf(buf, "%lu\n", sum);			\
+}								\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: [RFC] per thread page reservation patch
References: <20050103011113.6f6c8f44.akpm@osdl.org>
	<20050103114854.GA18408@infradead.org> <41DC2386.9010701@namesys.com>
	<1105019521.7074.79.camel@tribesman.namesys.com>
	<20050107144644.GA9606@infradead.org>
	<1105118217.3616.171.camel@tribesman.namesys.com>
	<20050107190545.GA13898@infradead.org>
From: Nikita Danilov <nikita@clusterfs.com>
Date: Fri, 07 Jan 2005 23:48:58 +0300
In-Reply-To: <20050107190545.GA13898@infradead.org> (Christoph Hellwig's
 message of "Fri, 7 Jan 2005 19:05:45 +0000")
Message-ID: <m1pt0hq81x.fsf@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Vladimir Saveliev <vs@namesys.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@infradead.org> writes:

>> diff -puN include/linux/gfp.h~reiser4-perthread-pages include/linux/gfp.h
>> --- linux-2.6.10-rc3/include/linux/gfp.h~reiser4-perthread-pages	2004-12-22 20:09:44.153164276 +0300

[...]

>
>> +int perthread_pages_count(void)
>> +{
>> +	return current->private_pages_count;
>> +}
>> +EXPORT_SYMBOL(perthread_pages_count);
>
> Again a completely useless wrapper.

I disagree. Patch introduces explicit API

int  perthread_pages_reserve(int nrpages, int gfp);
void perthread_pages_release(int nrpages);
int  perthread_pages_count(void);

sufficient to create and use per-thread reservations. Using
current->private_pages_count directly

 - makes API less uniform, not contained within single namespace
   (perthread_pages_*), and worse,

 - exhibits internal implementation detail to the user.

>

[...]

Nikita.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

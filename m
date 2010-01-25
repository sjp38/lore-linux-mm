Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 921AF6B0098
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 17:19:23 -0500 (EST)
Message-ID: <4B5E1868.6090204@bx.jp.nec.com>
Date: Mon, 25 Jan 2010 17:17:12 -0500
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH -tip 1/2 v2] add tracepoints for pagecache
References: <4B5A3D00.8080901@bx.jp.nec.com>	 <4B5A3DD5.3020904@bx.jp.nec.com> <1264213709.31321.401.camel@gandalf.stny.rr.com>
In-Reply-To: <1264213709.31321.401.camel@gandalf.stny.rr.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: rostedt@goodmis.org
Cc: linux-kernel@vger.kernel.org, lwoodman@redhat.com, linux-mm@kvack.org, mingo@elte.hu, tzanussi@gmail.com, riel@redhat.com, akpm@linux-foundation.org, fweisbec@gmail.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

(2010a1'01ae??22ae?JPY 21:28), Steven Rostedt wrote:
>> +TRACE_EVENT(remove_from_page_cache,
>> +
>> +	TP_PROTO(struct address_space *mapping, pgoff_t offset),
>> +
>> +	TP_ARGS(mapping, offset),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(dev_t, s_dev)
>> +		__field(ino_t, i_ino)
>> +		__field(pgoff_t, offset)
>> +		),
>> +
>> +	TP_fast_assign(
>> +		__entry->s_dev = mapping->host->i_sb->s_dev;
>> +		__entry->i_ino = mapping->host->i_ino;
>> +		__entry->offset = offset;
>> +		),
>> +
>> +	TP_printk("s_dev=%u:%u i_ino=%lu offset=%lu", MAJOR(__entry->s_dev),
>> +		MINOR(__entry->s_dev), __entry->i_ino, __entry->offset)
>> +);
>> +
> 
> The above qualify in converting to templates or DECLACE_TRACE_CLASS, and
> DEFINE_EVENT, That is, rename the above TRACE_EVENT into
> DECLARE_TRACE_CLASS, and then have the other one be a DEFINE_EVENT().
> See the trace/event/sched.h for examples.
> 
> The TRACE_EVENT can add a bit of code, so use DECLARE_TRACE_CLASS when
> possible and it will save on the size overhead.

Thank you for your information. I'll fix it next time.

Thanks,
Keiichi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

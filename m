From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch] mm: more likely reclaim MADV_SEQUENTIAL mappings II
References: <87r669fq2v.fsf@saeurebad.de> <87ljwhfo4e.fsf@saeurebad.de>
	<20081022152911.1CD9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Wed, 22 Oct 2008 09:15:14 +0200
In-Reply-To: <20081022152911.1CD9.KOSAKI.MOTOHIRO@jp.fujitsu.com> (KOSAKI
	Motohiro's message of "Wed, 22 Oct 2008 15:39:41 +0900 (JST)")
Message-ID: <87abcxksn1.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:

>> >> Is http://hannes.saeurebad.de/madvseq/ still true with this version?
>> >
>> > No, sorry, still running benchmarks on this version.  Coming up
>> > soon...
>> 
>> Ok, reran the tests I used for the data on this website and updated it.
>> Take a look.  I am quite overwhelmed by the results, hehe.
>> 
>> Kosaki-san, could you perhaps run the tests you did for the previous
>> patch on this one, too?  I am not getting any stable results for
>> throughput measuring...
>
> Usually, any reclaim throughput mesurement isn't stable.
> Then I used an average of five times mesurement.

Ah, okay.  I will give it another spin, too.

> Unfortunately, I can't understand I should mesure which patch combination
> because you and Nick post many patches of this issue related yesterday.
> Please let me know it?

mmotm
- the old mm-more-likely-reclaim-madv_sequential-mappings
+ Nick's mm: dont mark_page_accessed in fault path (from yesterday)
+ Apply this patch

Andrew's tree (not yet released) already has the first two changes, so
if he releases a new mmotm in the meantime, you only need this patch on
top of it.

        Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

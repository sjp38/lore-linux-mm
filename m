Date: Wed, 19 Dec 2007 13:09:10 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 02/20] make the inode i_mmap_lock a reader/writer lock
In-Reply-To: <200712191148.06506.nickpiggin@yahoo.com.au>
References: <20071218211548.784184591@redhat.com> <200712191148.06506.nickpiggin@yahoo.com.au>
Message-Id: <20071219124513.9853.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi

> > rmap:  try_to_unmap_file() required new cond_resched_rwlock().
> > To reduce code duplication, I recast cond_resched_lock() as a
> > [static inline] wrapper around reworked cond_sched_lock() =>
> > __cond_resched_lock(void *lock, int type).
> > New cond_resched_rwlock() implemented as another wrapper.
> 
> Reader/writer locks really suck in terms of fairness and starvation,
> especially when the read-side is common and frequent. (also, single
> threaded performance of the read-side is worse).

Agreed.

rwlock got bad performance some case. (especially on many cpu machine)

if many cpu grab read-lock on and off on many cpu system.
then at least 1 cpu always grab read lock and the cpu of waiting write-lock 
never get lock.

threrefore, rwlock often make performance weakness of stress.


I want know testcase for this patch and run it.
Do you have it?


/kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

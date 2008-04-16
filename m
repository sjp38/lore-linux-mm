Date: Wed, 16 Apr 2008 11:23:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080416112341.ef1d5452.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080416092334.2dabce2c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	<20080415191350.0dc847b6.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804151227050.1785@schroedinger.engr.sgi.com>
	<20080416092334.2dabce2c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Apr 2008 09:23:34 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> What I experienced was.
> ==
> %echo offline > /sys/device/system/memoryXXXX/state
> ...wait for a minute
> Ctrl-C
> % sync
> % sync
> % echo offline > /sys/device/system/memoryXXXX/state
> ...wait for a minute
> % echo 3 > /proc/sys/vm/drop_caches
> % echo offline > /sys/device/system/memoryXXXX/state
> success.
> ==
> 
> I'll see what happens wish -EBUSY but maybe no help...
> 
Adding -EBUSY was no help. some pages seems never to be Uptodate...

== prinkt result  ==
not-up-to-date a000400144d83768 60000000000801
not-up-to-date a000400144d83d98 60000000000801
not-up-to-date a000400144d840b0 60000000000801
not-up-to-date a000400144d842a8 60000000000801
not-up-to-date a000400144d8a638 60000000000801
not-up-to-date a000400144d8f780 60000000000801
not-up-to-date a000400144d901a0 60000000000801
not-up-to-date a000400144d915e0 60000000000801
not-up-to-date a000400144d937a0 60000000000801
not-up-to-date a000400144d95d50 60000000000801
not-up-to-date a000400144d97028 60000000000801
not-up-to-date a000400144d97e38 60000000000801
not-up-to-date a000400144d99398 60000000000801
not-up-to-date a000400144d995d8 60000000000801
not-up-to-date a000400144df4e98 60000000000801
not-up-to-date a000400144df5ee8 60000000000801
not-up-to-date a000400144df7010 60000000000801
not-up-to-date a000400144df7400 60000000000801
== repeated.

Hmm...

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

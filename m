Received: by gxk8 with SMTP id 8so10921824gxk.14
        for <linux-mm@kvack.org>; Tue, 09 Sep 2008 09:39:22 -0700 (PDT)
Message-ID: <48C6A6B0.8090606@gmail.com>
Date: Tue, 09 Sep 2008 18:39:12 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH -mm] cgroup: limit the amount of dirty file pages
References: <48C6987D.2050905@gmail.com> <11118085.1220977593430.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <11118085.1220977593430.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Carl Henrik Lunde <chlunde@ping.uio.no>, Divyesh Shah <dpshah@google.com>, Naveen Gupta <ngupta@google.com>, Fernando Luis V?zquez Cao <fernando@oss.ntt.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, Marco Innocenti <m.innocenti@cineca.it>, Satoshi UCHIDA <s-uchida@ap.jp.nec.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Matt Heaton <matt@bluehost.com>, David Radford <dradford@bluehost.com>, containers@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
>> This is a totally experimental patch against 2.6.27-rc5-mm1.
>>
>> It allows to control how much dirty file pages a cgroup can have at any
>> given time. This feature is supposed to be strictly connected to a
>> generic cgroup IO controller (see below).
>>
>> Interface: a new entry "filedirty" is added to the file memory.stat,
>> reporting the number of dirty file pages (in pages), and a new file
>> memory.file_dirty_limit_in_pages is added in the cgroup filesystem to
>> show/set the current limit.
>>
> Before staring patch review, why not dirty_ratio per memcg ?
> Is there difficult implementation issue ?

mmmh.. maybe it's a bit more complex (would add some overhead?) to
translate the limit from dirty_ratio into pages or bytes, because we
need to evaluate it in function of the per-cgroup dirtyable memory (lru
pages and free pages I suppose). Maybe it's enough to implement it
directly in determine_dirtyable_memory().

I can try to implement it and post a new patch.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

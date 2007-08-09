Date: Thu, 9 Aug 2007 08:25:11 +0200
From: Lionel Elie Mamane <lionel@mamane.lu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070809062511.GA23435@capsaicin.mamane.lu>
References: <20070803123712.987126000@chello.nl> <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <20070804163733.GA31001@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070804163733.GA31001@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingcha@pimp.vs19.net
List-ID: <linux-mm.kvack.org>

On Sat, Aug 04, 2007 at 06:37:33PM +0200, Ingo Molnar wrote:
> * Linus Torvalds <torvalds@linux-foundation.org> wrote:

>> The fact is, ext3 *sucks* at fsync. I hate hate hate it. It's
>> totally unusable, imnsho.

> yeah, it's really ugly. But otherwise i've got no real complaint
> about ext3 - with the obligatory qualification that
> "noatime,nodiratime" in /etc/fstab is a must. This speeds up things
> very visibly (...). So for most file workloads we give Windows a
> 20%-30% performance edge, for almost nothing.

It has been years since I used MS Windows much, but from my memories
of my these days, I was under the impression that it (at least the NT
line, the only surviving line these days) also maintained "last
accessed" times. Except I only ever saw it at "right now" because the
file explorer ... accesses the file before getting this metadata or
something like that (when you right-click on a file and ask for its
properties). It has creation and last modification time, too.

So, if my memories are correct, there is no performance edge to be
conceded by having atime (but one to be gained by not having atime).

-- 
Lionel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

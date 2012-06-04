Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 7F6AC6B005C
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 23:28:37 -0400 (EDT)
Message-ID: <1338780504.25653.18.camel@cr0>
Subject: Re: [RFC Patch] fs: implement per-file drop caches
From: Cong Wang <amwang@redhat.com>
Date: Mon, 04 Jun 2012 11:28:24 +0800
In-Reply-To: <20424.48827.778644.310736@quad.stoffel.home>
References: <1338385120-14519-1-git-send-email-amwang@redhat.com>
	 <4FC6393B.7090105@draigBrady.com> <1338445233.19369.21.camel@cr0>
	 <4FC70FFE.50809@gmail.com> <1338466281.19369.44.camel@cr0>
	 <4FC7C1CD.7020701@gmail.com> <1338550337.17012.27.camel@cr0>
	 <20424.48827.778644.310736@quad.stoffel.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, =?ISO-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2012-06-01 at 09:08 -0400, John Stoffel wrote:
> >>>>> "Cong" == Cong Wang <amwang@redhat.com> writes:
> 
> Cong> Yeah, at least John Stoffel expressed his interests on this, as
> Cong> a sysadmin. So I believe there are some people need it.
> 
> I expressed an interest if there was a way to usefully *find* the
> processes that are hogging cache.  Without a reporting mechanism of
> cache usage on per-file or per-process manner, then I don't see a
> great use for this.  It's just simpler to drop all the caches when you
> hit a wall.  
> 
> Cong> Now the problem is that I don't find a proper existing utility
> Cong> to patch, maybe PA!draig has any hints on this? Could this
> Cong> feature be merged into some core utility? Or I have to write a
> Cong> new utility for this?
> 
> I'd write a new tutorial utility, maybe you could call it 'cache_top'
> and have it both show the biggest users of cache, as well as exposing
> your new ability to drop the cache on a per-fd basis.
> 
> It's really not much use unless we can measure it.

Fair enough.

We could do that with Keiichi's page cache tracepoint patches:
https://lkml.org/lkml/2011/7/18/326

with that patch, we can measure page caches with `perf`. I tried to
carry Keiichi's patches, but those patch depend on other patches too,
the main problem is still translating the inode number to file name for
user-space users to read, which is not trivial at all.

Also, will vmtouch work for you too? You can get it at
http://hoytech.com/vmtouch/

I can patch it too if you want.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

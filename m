Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 5F00E8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 16:10:05 -0400 (EDT)
Date: Fri, 11 May 2012 13:10:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 43227] New: BUG: Bad page state in process wcg_gfam_6.11_i
Message-Id: <20120511131003.282e9daa.akpm@linux-foundation.org>
In-Reply-To: <20120511200615.GA12268@redhat.com>
References: <bug-43227-27@https.bugzilla.kernel.org/>
	<20120511125921.a888e12c.akpm@linux-foundation.org>
	<20120511200615.GA12268@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, sliedes@cc.hut.fi

On Fri, 11 May 2012 16:06:15 -0400
Dave Jones <davej@redhat.com> wrote:

> On Fri, May 11, 2012 at 12:59:21PM -0700, Andrew Morton wrote:
>  
>  > > https://bugzilla.kernel.org/show_bug.cgi?id=43227
>  > > 
>  > > [67031.755786] BUG: Bad page state in process wcg_gfam_6.11_i  pfn:02519
>  > > [67031.755790] page:ffffea0000094640 count:0 mapcount:0 mapping:         
>  > > (null) index:0x7f1eb293b
>  > > [67031.755792] page flags: 0x4000000000000014(referenced|dirty)
>  > 
>  > AFAICT we got this warning because the page allocator found a free page
>  > with PG_referenced and PG_dirty set.
>  > 
>  > It would be a heck of a lot more useful if we'd been told about this
>  > when the page was freed, not when it was reused!  Can anyone think of a
>  > reason why PAGE_FLAGS_CHECK_AT_FREE doesn't include these flags (at
>  > least)?
> 
> We got a similar bug reported in Fedora against 3.3.4 yesterday.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=820603
> 
> :[162276.196730] BUG: Bad page state in process transmission-gt  pfn:1bddff
> :[162276.196735] page:ffffea0006f77fc0 count:0 mapcount:0 mapping: (null) index:0x7f2fdb962
> :[162276.196737] page flags: 0x40000000000014(referenced|dirty)
> 
> Different trace, but same result.
> 

That narrows it down to a 3.3.2 -> 3.3.4 regression, perhaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

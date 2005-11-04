Date: Thu, 3 Nov 2005 22:16:09 -0800
From: bron@bronze.corp.sgi.com (Bron Nelson)
Message-Id: <200511040616.WAA21225@bronze.corp.sgi.com>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com>
    <200511021747.45599.rob@landley.net> <43699573.4070301@yahoo.com.au>
    <200511030007.34285.rob@landley.net>
    <20051103163555.GA4174@ccure.user-mode-linux.org>
    <1131035000.24503.135.camel@localhost.localdomain>
    <20051103205202.4417acf4.akpm@osdl.org> <20051103213538.7f037b3a.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@osdl.org>
Cc: lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kravetz@us.ibm.com, mbligh@mbligh.org, mel@csn.ul.ie, haveblue@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, mingo@elte.hu, gh@us.ibm.com, nickpiggin@yahoo.com.au, rob@landley.net, jdike@addtoit.com, pbadari@gmail.com
List-ID: <linux-mm.kvack.org>

> I was kind of thinking that the stats should be per-process (actually
> per-mm) rather than bound to cpusets.  /proc/<pid>/pageout-stats or something.

The particular people that I deal with care about constraining things
on a per-cpuset basis, so that is the information that I personally am
looking for.  But it is simple enough to map tasks to cpusets and vice-versa,
so this is not really a serious consideration.  I would generically be in
favor of the per-process stats (even though the application at hand is
actually interested in the cpuset aggregate stats), because we can always
produce an aggregate from the detailed, but not vice-versa.  And no doubt
some future as-yet-unimagined application will want per-process info.


--
Bron Campbell Nelson      bron@sgi.com
These statements are my own, not those of Silicon Graphics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

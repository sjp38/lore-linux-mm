Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E770D9000C6
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 08:25:13 -0400 (EDT)
Date: Mon, 3 Oct 2011 15:25:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 7/8] Display current tcp memory allocation in kmem
 cgroup
Message-ID: <20111003122511.GA29982@shutemov.name>
References: <1317637123-18306-1-git-send-email-glommer@parallels.com>
 <1317637123-18306-8-git-send-email-glommer@parallels.com>
 <20111003121446.GD29312@shutemov.name>
 <4E89A846.1010200@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E89A846.1010200@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, avagin@parallels.com

On Mon, Oct 03, 2011 at 04:19:18PM +0400, Glauber Costa wrote:
> On 10/03/2011 04:14 PM, Kirill A. Shutemov wrote:
> > On Mon, Oct 03, 2011 at 02:18:42PM +0400, Glauber Costa wrote:
> >> This patch introduces kmem.tcp_current_memory file, living in the
> >> kmem_cgroup filesystem. It is a simple read-only file that displays the
> >> amount of kernel memory currently consumed by the cgroup.
> >>
> >> Signed-off-by: Glauber Costa<glommer@parallels.com>
> >> CC: David S. Miller<davem@davemloft.net>
> >> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
> >> CC: Eric W. Biederman<ebiederm@xmission.com>
> >> ---
> >>   Documentation/cgroups/memory.txt |    1 +
> >>   mm/memcontrol.c                  |   11 +++++++++++
> >>   2 files changed, 12 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> >> index 1ffde3e..f5a539d 100644
> >> --- a/Documentation/cgroups/memory.txt
> >> +++ b/Documentation/cgroups/memory.txt
> >> @@ -79,6 +79,7 @@ Brief summary of control files.
> >>    memory.independent_kmem_limit	 # select whether or not kernel memory limits are
> >>   				   independent of user limits
> >>    memory.kmem.tcp.max_memory      # set/show hard limit for tcp buf memory
> >> + memory.kmem.tcp.current_memory  # show current tcp buf memory allocation
> >
> > Both are in pages, right?
> > Shouldn't it be scaled to bytes and named uniform with other memcg file?
> > memory.kmem.tcp.limit_in_bytes/usage_in_bytes.
> >
> You are absolutely correct.
> Since the internal tcp comparison works, I just ended up never noticing 
> this.

Should we have failcnt and max_usage_in_bytes for tcp as well?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

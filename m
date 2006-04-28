Date: Fri, 28 Apr 2006 13:15:33 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Fwd: Strange VM behavior on kernel 2.6.14.3]
Message-Id: <20060428131533.5da621b7.akpm@osdl.org>
In-Reply-To: <1146254890.4134.12.camel@dmt.cnet>
References: <1146254890.4134.12.camel@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: linux-mm@kvack.org, vito@hostway.com
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@kvack.org> wrote:
>
> Vito, 
> 
> There have been some changes after 2.6.14 in the reclaim code which
> might 
> affect the problem you're seeing wrt large chunks of pagecache being
> freed.
> 
> Folks, any ideas on what might be causing this? Please refer to document
> at the URL below, it contains quite some information.
> 
> -----
> 
> Perhaps you can point me at a patch or some kind of information to help
> resolve/understand this problem, I have published some graphs and other
> data
> explaining the problem here on the web:
> http://shells.gnugeneration.com/~swivel/pop_comparisons/04-26-2006/
> 
> I might give the latest 2.6 kernel off kernel.org a try, as it looks
> like there has been some serious activity in the vm code lately...
> 
> Except this is in production and I'd rather not fix one bug while
> potentially adding a handful of new ones... a patch fixing this specific
> problem on our kernel would be ideal.
> 

My first thought would be that some really large file (or files) hit the
tail of the inode_unused and we ended up shooting down the whole lot in one
hit so the inode itself could be reclaimed.

But Vito has thought of that and thinks it isn't happening.

Perhaps it's a bug, and page reclaim has gone nutso, but I don't recall
having seen such a thing before.

It's an x86-32 highmem machine, isn't it?

A more detailed description of what the application is doing would be
useful - number of files, average and max file size, access patterns, etc.

Also, as always, testing on contemporary kernels.

A potentially useful thing would be to capture /proc/meminfo and
/proc/vmstat to a file every ten seconds or so, and to then pick out a
record from each of those /proc files from both sides of one of these
events, so we can see what changed in them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

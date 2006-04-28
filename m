Subject: [Fwd: Strange VM behavior on kernel 2.6.14.3]
From: Marcelo Tosatti <marcelo@kvack.org>
Content-Type: text/plain
Date: Fri, 28 Apr 2006 17:08:10 -0300
Message-Id: <1146254890.4134.12.camel@dmt.cnet>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, vito@hostway.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Vito, 

There have been some changes after 2.6.14 in the reclaim code which
might 
affect the problem you're seeing wrt large chunks of pagecache being
freed.

Folks, any ideas on what might be causing this? Please refer to document
at the URL below, it contains quite some information.

-----

Perhaps you can point me at a patch or some kind of information to help
resolve/understand this problem, I have published some graphs and other
data
explaining the problem here on the web:
http://shells.gnugeneration.com/~swivel/pop_comparisons/04-26-2006/

I might give the latest 2.6 kernel off kernel.org a try, as it looks
like there has been some serious activity in the vm code lately...

Except this is in production and I'd rather not fix one bug while
potentially adding a handful of new ones... a patch fixing this specific
problem on our kernel would be ideal.

Thanks in advance,
Vito Caputo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

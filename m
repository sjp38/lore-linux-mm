Subject: Re: 2.6.3-rc2-mm1
From: Torrey Hoffman <thoffman@arnor.net>
In-Reply-To: <20040212015710.3b0dee67.akpm@osdl.org>
References: <20040212015710.3b0dee67.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1076630675.6006.6.camel@moria.arnor.net>
Mime-Version: 1.0
Date: Thu, 12 Feb 2004 16:04:35 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux-Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2004-02-12 at 01:57, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc2/2.6.3-rc2-mm1/

[... list of many patches]

>  bk-ieee1394.patch

I reported a bug in 2.6.2-rc3-mm1 and was asked to retest... result is
it's still broken.  The result is the same - even a little worse now, it
won't get as far as running init so I have no log to post.  This machine
has no serial port and I haven't tried the network logging stuff yet...

But the oops looked very similar.  At least the function names and the
references to ieee1394 are the same.  The 2.6.2-rc3-mm1 oops was:

> ieee1394: Host added: ID:BUS[0-00:1023]  GUID[00508d0000f42af5]
> Badness in kobject_get at lib/kobject.c:431
> Call Trace:
>  [<c02078dc>] kobject_get+0x3c/0x50
>  [<c0272fd1>] get_device+0x11/0x20
>  [<c0273c68>] bus_for_each_dev+0x78/0xd0
>  [<fc876185>] nodemgr_node_probe+0x45/0x100 [ieee1394]
>  [<fc876030>] nodemgr_probe_ne_cb+0x0/0x90 [ieee1394]
>  [<fc87654b>] nodemgr_host_thread+0x14b/0x180 [ieee1394]
>  [<fc876400>] nodemgr_host_thread+0x0/0x180 [ieee1394]
>  [<c010b285>] kernel_thread_helper+0x5/0x10

And you (Andrew said)
> "Ben and Greg are currently arguing over whose fault this is ;)"
...
> "There will be a big 1394 update in 2.6.2-mm2.  Could you please
retest and let us know?"

-- 
Torrey Hoffman <thoffman@arnor.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

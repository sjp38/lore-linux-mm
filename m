Date: Thu, 26 Aug 2004 16:28:55 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4
    16gb
In-Reply-To: <1093470564.5677.1920.camel@knk>
Message-ID: <Pine.LNX.4.44.0408261605020.2115-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2004, keith wrote:
> With the patch I only get 82294 inodes.  Hmmmm.... I don't have any
> lowmem issues but I can't create too many files.  

I get 107701 for my LowTotal 861608 kB, but your LowTotal is 658808 kB.

I'm not saying that default (in your case 82294) is the highest allowable,
just a safe default, consistent with what was offered before when no
highmem.  If the default is to allow half of RAM to be occupied by tmpfs
(highmem and swappable) data blocks, it seems appropriate to default to
a much smaller fraction of lowmem for the unswappable metadata; but I
may be overdoing that, I'm not sure.

I expect in your case (not wanting the lowmem for anything else much)
you'll survive with nr_inodes=400000: you can try that, and push it up
to breaking point if you like (one reason I don't want to enforce an
upper limit in the kernel, just a default).  But I don't expect you to
survive with nr_inodes=700000.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

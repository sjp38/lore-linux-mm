Date: Fri, 11 Mar 2005 21:19:16 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] x86: fix booting non-NUMA system with NUMA config
In-Reply-To: <1110573471.557.73.camel@localhost>
Message-ID: <Pine.LNX.4.61.0503112115180.9801@goblin.wat.veritas.com>
References: <Pine.LNX.4.61.0503111922520.9403@goblin.wat.veritas.com>
    <1110573471.557.73.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Mar 2005, Dave Hansen wrote:
> 
> Hugh, you caught me.  There is, indeed, a bug booting with
> CONFIG_NUMA=y, CONFIG_X86_GENERICARCH=y, and booting on a non-NUMA
> system.  While not the most common configuration, it should surely be
> supported.

Lovely, Dave, thanks a lot, I confirm your patch works for me.
Now I can impress the neighbours again with my little "NUMA" system.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

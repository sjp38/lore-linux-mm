Date: Mon, 5 Aug 2002 09:53:07 -0700 (PDT)
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: How to compile kernel fast
In-Reply-To: <Pine.SOL.4.33.0208051244340.24796-100000@azure.engin.umich.edu>
Message-ID: <Pine.LNX.4.33L2.0208050950290.6273-100000@dragon.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hai Huang <haih@engin.umich.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Aug 2002, Hai Huang wrote:

| I've noticed that 2.4 kernel compile is much time consuming than 2.2.
| Even very small changes would cause a chain reaction to force other source
| files to be recompiled.  Did anyone ever experienced using pvm or
| something similar to hasten this process with multiple machines running
| parallel?  Well, this might not be the right ng to post this, but I figure
| VM's dependency is pretty widespread in the kernel, so this is especially
| problemsome in this area.  Any good suggestion is welcome.  Thanks.

There have been some build dependency cleanups in 2.5 that
reduce the number of rebuilt files.
Also, if you are compiling multiple times, you could consider
using compiler-cache (ccache):  http://ccache.samba.org

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

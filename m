Date: Mon, 16 Feb 2004 07:47:21 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] 2.6.3-rc3-mm1: align scan_page per node
Message-ID: <7090000.1076946440@[10.10.2.4]>
In-Reply-To: <4030BB86.8060206@cyberone.com.au>
References: <4030BB86.8060206@cyberone.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>, Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <Nikita@Namesys.COM>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Nick Piggin <piggin@cyberone.com.au> wrote (on Monday, February 16, 2004 23:45:58 +1100):

> Ok ok, I'll do it... is this the right way to go about it?
> I'm assuming it is worth doing?


What were the include dependencies you ran into originally? Were they 
not fixable somehow? They probably need fixing anyway ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

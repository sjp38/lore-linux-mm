Date: Tue, 15 Mar 2005 22:37:17 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Move code to isolate LRU pages into separate function
Message-Id: <20050315223717.2a0f80e6.akpm@osdl.org>
In-Reply-To: <20050315195452.GE19113@localhost>
References: <20050314214941.GP3286@localhost>
	<20050315195452.GE19113@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin Hicks <mort@sgi.com> wrote:
>
> On Mon, Mar 14, 2005 at 04:49:41PM -0500, Martin Hicks wrote:
>  > Hi,
>  > 
>  > I noticed that the loop to pull pages out of the LRU lists for
>  > processing occurred twice.  This just sticks that code into a separate
>  > function to improve readability.
>  > 
>  > The patch is against 2.6.11-mm2 but should apply to anything recent.
>  > Build and boot tested on sn2.
> 
>  Whoops.  I was double-incrementing scanned, so only half the pages that
>  you asked for were being scanned.
> 
>  This version fixes that and also allows passing in a NULL scanned
>  argument if you don't care how many pages were scanned.
> 

But neither caller passes in a NULL argument.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

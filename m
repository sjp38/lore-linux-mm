Date: Tue, 4 Nov 2008 10:16:52 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] [REPOST #2] mm: show node to memory section
	relationship with symlinks in sysfs
Message-ID: <20081104091652.GH23790@elte.hu>
References: <20081103234808.GA13716@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081103234808.GA13716@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Nish Aravamudan <nish.aravamudan@gmail.com>
List-ID: <linux-mm.kvack.org>

* Gary Hade <garyhade@us.ibm.com> wrote:

> Show node to memory section relationship with symlinks in sysfs

nice change.

>  arch/x86/mm/init_32.c                          |    2 
>  arch/x86/mm/init_64.c                          |    2 

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

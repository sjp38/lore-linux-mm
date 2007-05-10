Subject: Re: [RFC] memory hotremove patch take 2 [01/10] (counter of removable page)
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
	<20070509120132.B906.Y-GOTO@jp.fujitsu.com>
From: Andi Kleen <andi@firstfloor.org>
Date: 10 May 2007 15:44:08 +0200
In-Reply-To: <20070509120132.B906.Y-GOTO@jp.fujitsu.com>
Message-ID: <p73bqgsg5ef.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Yasunori Goto <y-goto@jp.fujitsu.com> writes:


(not a full review, just something I noticed)
> @@ -352,6 +352,8 @@ struct sysinfo {
>  	unsigned short pad;		/* explicit padding for m68k */
>  	unsigned long totalhigh;	/* Total high memory size */
>  	unsigned long freehigh;		/* Available high memory size */
> +	unsigned long movable;		/* pages used only for data */
> +	unsigned long free_movable;	/* Avaiable pages in movable */

You can't just change that structure, it is exported to user space.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 6 Feb 2006 17:39:36 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm: implement swap prefetching
Message-Id: <20060206173936.1a331291.akpm@osdl.org>
In-Reply-To: <200602071229.25793.kernel@kolivas.org>
References: <200602071028.30721.kernel@kolivas.org>
	<20060206163842.7ff70c49.akpm@osdl.org>
	<200602071229.25793.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Con Kolivas <kernel@kolivas.org> wrote:
>
>  > > +/* Last total free pages */
>  > > +static unsigned long last_free = 0;
>  > > +static unsigned long temp_free = 0;
>  >
>  > Unneeded initialisation.
> 
>  Very first use of both of these variables depends on them being initialised.

All bss is initialised to zero at bootup.  So all the `= 0' is doing here
is moving these variables from .bss to .data, and taking up extra space in
vmlinux.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

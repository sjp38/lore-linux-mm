Date: Thu, 15 May 2003 01:42:07 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-Id: <20030515014207.64be0afa.akpm@digeo.com>
In-Reply-To: <20030515013245.58bcaf8f.akpm@digeo.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
	<20030513181018.4cbff906.akpm@digeo.com>
	<18240000.1052924530@baldur.austin.ibm.com>
	<20030514103421.197f177a.akpm@digeo.com>
	<82240000.1052934152@baldur.austin.ibm.com>
	<20030515004915.GR1429@dualathlon.random>
	<20030515013245.58bcaf8f.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andrea@suse.de, dmccr@us.ibm.com, mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> wrote:
>
> So the mm/memory.c part would look something like:

er, right patch, wrong concept.  That's the "check i_size after taking
page_table_lock" patch.

It's actually not too bad.  Yes, there's 64-bit arith involved, but it is
only a shift.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

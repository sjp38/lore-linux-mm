Date: Wed, 14 May 2003 11:17:48 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-Id: <20030514111748.57670088.akpm@digeo.com>
In-Reply-To: <99000000.1052935556@baldur.austin.ibm.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
	<3EC15C6D.1040403@kolumbus.fi>
	<199610000.1052864784@baldur.austin.ibm.com>
	<20030513181018.4cbff906.akpm@digeo.com>
	<18240000.1052924530@baldur.austin.ibm.com>
	<20030514103421.197f177a.akpm@digeo.com>
	<82240000.1052934152@baldur.austin.ibm.com>
	<20030514105706.628fba15.akpm@digeo.com>
	<99000000.1052935556@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> > It would be nice to make them go away - they cause problems.
> 
>  Definitely.  We almost have the pieces necessary to detect it and/or
>  prevent it, but the info isn't in quite the right layer at the right time.
>  If it weren't for the lock order problem with mmap_sem we could have nailed
>  it that way.  Sigh.

I think it might be sufficient to re-check the page against i_size
after IO completion in filemap_nopage().
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

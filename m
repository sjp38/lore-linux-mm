Date: Wed, 14 May 2003 13:05:56 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <99000000.1052935556@baldur.austin.ibm.com>
In-Reply-To: <20030514105706.628fba15.akpm@digeo.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
 <3EC15C6D.1040403@kolumbus.fi><199610000.1052864784@baldur.austin.ibm.com>
 <20030513181018.4cbff906.akpm@digeo.com>
 <18240000.1052924530@baldur.austin.ibm.com>
 <20030514103421.197f177a.akpm@digeo.com>
 <82240000.1052934152@baldur.austin.ibm.com>
 <20030514105706.628fba15.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, May 14, 2003 10:57:06 -0700 Andrew Morton <akpm@digeo.com>
wrote:

> yes.  It's a very complex way of allocating anonymous memory.

Yep.  And randomly, at that.

> I am told that Stephen, Linus and others discussed this at length at KS a
> couple of years ago and the upshot was that the application is racy anyway
> and there's nothing wrong with it.
> 
> Hugh calls these "Morton pages" but it wasn't me and nobody saw me do it.
> 
> It would be nice to make them go away - they cause problems.

Definitely.  We almost have the pieces necessary to detect it and/or
prevent it, but the info isn't in quite the right layer at the right time.
If it weren't for the lock order problem with mmap_sem we could have nailed
it that way.  Sigh.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

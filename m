Date: Wed, 14 May 2003 10:34:21 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-Id: <20030514103421.197f177a.akpm@digeo.com>
In-Reply-To: <18240000.1052924530@baldur.austin.ibm.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
	<3EC15C6D.1040403@kolumbus.fi>
	<199610000.1052864784@baldur.austin.ibm.com>
	<20030513181018.4cbff906.akpm@digeo.com>
	<18240000.1052924530@baldur.austin.ibm.com>
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
> Which the application thinks is still part of the file, and will expect its
>  changes to be written back.

How so?  Truncate will chop the page off the mapping - it doesn't
miss any pages.

Truncate has to wait for the page lock, so the page may be removed from the
mapping shortly after the major fault's IO has completed.  Maybe that's
what you are seeing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

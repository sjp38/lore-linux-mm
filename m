Date: Wed, 14 May 2003 14:07:45 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <127820000.1052939265@baldur.austin.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0305141503010.10617-100000@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.44.0305141503010.10617-100000@chimarrao.boston.redha
 t.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@digeo.com>
Cc: mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, May 14, 2003 15:04:55 -0400 Rik van Riel <riel@redhat.com>
wrote:

>> Not to mention they could end up being outside of any VMA,
>> meaning there's no sane way to deal with them.
> 
> I hate to follow up to my own email, but the fact that
> they're not in any VMA could mean we leak these pages
> at exit() time.

Well, they are still inside the vma.  Truncate doesn't shrink the vma.  It
just generates SIGBUS when the app tries to fault the pages in.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

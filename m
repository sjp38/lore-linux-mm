Date: Wed, 14 May 2003 10:02:56 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <18730000.1052924576@baldur.austin.ibm.com>
In-Reply-To: <20030513181022.6dbc5418.akpm@digeo.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
 <3EC15C6D.1040403@kolumbus.fi><199610000.1052864784@baldur.austin.ibm.com>
 <20030513224929.GX8978@holomorphy.com>
 <220550000.1052866808@baldur.austin.ibm.com>
 <20030513181022.6dbc5418.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: wli@holomorphy.com, mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On Tuesday, May 13, 2003 18:10:22 -0700 Andrew Morton <akpm@digeo.com>
wrote:

>>  Can anyone think of any gotchas to this solution?
> 
> mmap_sem nests outside i_shared_sem.

Rats.  You're right.  Time to consider alternatives.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

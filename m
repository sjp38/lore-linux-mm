Date: Tue, 13 May 2003 18:28:20 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <266860000.1052868500@baldur.austin.ibm.com>
In-Reply-To: <20030513232038.GB8978@holomorphy.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
 <3EC15C6D.1040403@kolumbus.fi> <199610000.1052864784@baldur.austin.ibm.com>
 <20030513224929.GX8978@holomorphy.com>
 <220550000.1052866808@baldur.austin.ibm.com>
 <20030513231139.GZ8978@holomorphy.com>
 <247390000.1052867776@baldur.austin.ibm.com>
 <20030513232038.GB8978@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Mika Penttil? <mika.penttila@kolumbus.fi>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--On Tuesday, May 13, 2003 16:20:38 -0700 William Lee Irwin III
<wli@holomorphy.com> wrote:

> The mmap_sem works because then ->i_size can't be sampled by
> filemap_nopage() before the pagetable wiping operation starts.

So why isn't that the right way to do it?  Waiting for mmap_sem guarantees
we won't catch a page fault in flight, which is the cause of the problem in
the first place.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

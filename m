Date: Tue, 13 May 2003 16:29:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <20030513232930.GD8978@holomorphy.com>
References: <154080000.1052858685@baldur.austin.ibm.com> <3EC15C6D.1040403@kolumbus.fi> <199610000.1052864784@baldur.austin.ibm.com> <20030513224929.GX8978@holomorphy.com> <220550000.1052866808@baldur.austin.ibm.com> <20030513231139.GZ8978@holomorphy.com> <247390000.1052867776@baldur.austin.ibm.com> <20030513232038.GB8978@holomorphy.com> <266860000.1052868500@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <266860000.1052868500@baldur.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Mika Penttil? <mika.penttila@kolumbus.fi>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tuesday, May 13, 2003 16:20:38 -0700 William Lee Irwin III <wli@holomorphy.com> wrote:
>> The mmap_sem works because then ->i_size can't be sampled by
>> filemap_nopage() before the pagetable wiping operation starts.

On Tue, May 13, 2003 at 06:28:20PM -0500, Dave McCracken wrote:
> So why isn't that the right way to do it?  Waiting for mmap_sem guarantees
> we won't catch a page fault in flight, which is the cause of the problem in
> the first place.

Oh it works fine, it's just the explanation for why it's sufficient I
was looking for.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

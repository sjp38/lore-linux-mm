Date: Tue, 1 Jul 2003 04:08:58 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.73-mm2
Message-ID: <20030701110858.GF26348@holomorphy.com>
References: <20030701105134.GE26348@holomorphy.com> <Pine.LNX.4.44.0307011202550.1217-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0307011202550.1217-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jul 2003, William Lee Irwin III wrote:
>> Well, I was mostly looking for getting handed back 0 when lowmem is
>> empty; I actually did realize they didn't give entirely accurate counts
>> of free lowmem pages.

On Tue, Jul 01, 2003 at 12:08:03PM +0100, Hugh Dickins wrote:
> I'm not pleading for complete accuracy, but nr_free_buffer_pages()
> will never hand back 0 (if your system managed to boot).
> It's a static count of present_pages (adjusted), not of
> free pages.  Or am I misreading nr_free_zone_pages()?

You're right. Wow, that's even more worse than I suspected.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Thu, 16 Jun 2005 15:42:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.12-rc6-mm1 & 2K lun testing
Message-ID: <20050616224230.GD3913@holomorphy.com>
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com> <20050616002451.01f7e9ed.akpm@osdl.org> <1118951458.4301.478.camel@dyn9047017072.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1118951458.4301.478.camel@dyn9047017072.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 16, 2005 at 12:50:59PM -0700, Badari Pulavarty wrote:
> Yes. I am using CFQ scheduler. I changed nr_requests to 4 for all
> my devices. I also changed "min_free_kbytes" to 64M.
> Response time is still bad. Here is the vmstat, meminfo, slabinfo
> and profle output. I am not sure why profile output shows 
> default_idle(), when vmstat shows 100% CPU sys.

It's because you're sorting on the third field of readprofile(1),
which is pure gibberish. Undoing this mistake will immediately
enlighten you.

Also, turn off slab poisoning when doing performance analyses.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Wed, 7 May 2003 05:06:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
Message-ID: <20030507120624.GZ8978@holomorphy.com>
References: <20030506232326.7e7237ac.akpm@digeo.com> <3EB8DBA0.7020305@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3EB8DBA0.7020305@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2003 at 12:10:40PM +0200, Helge Hafting wrote:
> 2.5.69-mm1 is fine, 2.5.69-mm2 panics after a while even under very
> light load.

Could you try testing with the slabification patch backed out?

Thanks.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

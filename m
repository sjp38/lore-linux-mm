Date: Tue, 15 Feb 2005 05:05:06 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview
Message-ID: <20050215110506.GD19658@lnx-holt.americas.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com> <m1vf8yf2nu.fsf@muc.de> <42114279.5070202@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42114279.5070202@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Andi Kleen <ak@muc.de>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 14, 2005 at 06:29:45PM -0600, Ray Bryant wrote:
> which is what you are asking for, I think.  The library's job
> (in addition to suspending all of the processes in the list for
> the duration of the migration operation, plus do some other things
> that are specific to sn2 hardware) would be to examine the

You probably want the batch scheduler to do the suspend/resume as it
may be parking part of the job on nodes that have memory but running
processes of a different job while moving a job out of the way for a
big-mem app that wants to run on one of this jobs nodes.

> do memory placement by first touch, during initialization.  This is,
> in part, because most of our codes originate on non-NUMA systems,
> and we've typically done very just what is necessary to make them

Software Vendors tend to be very reluctant to do things for a single
architecture unless there are clear wins.

Thanks,
Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

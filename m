Date: Tue, 10 Jun 2003 02:20:48 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.70-mm6
Message-ID: <20030610092048.GB26348@holomorphy.com>
References: <46580000.1055180345@flay> <Pine.LNX.4.51.0306092017390.25458@dns.toxicfilms.tv> <51250000.1055184690@flay> <Pine.LNX.4.51.0306092140450.32624@dns.toxicfilms.tv> <20030609200411.GA26348@holomorphy.com> <Pine.LNX.4.51.0306101052160.14891@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.51.0306101052160.14891@dns.toxicfilms.tv>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, efault@gmx.de
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>> How about one or the other of these two? (not both at once, though,
>> they appear to clash).

On Tue, Jun 10, 2003 at 10:54:55AM +0200, Maciej Soltysiak wrote:
> Success, no audio skipps with galbraith.patch and mm6.

Mike, any chance you can turn your series of patches into one that
applies atop mingo's intra-timeslice priority preemption patch? If
not, I suppose someone else could.

There also appears to be some kind of issue with using monotonic_clock()
with timer_pit as well as some locking overhead concerns. Something
should probably be done about those things before trying to merge the
fine-grained time accounting patch.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Fri, 06 Aug 2004 14:15:45 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [proc.txt] Fix /proc/pid/statm documentation
Message-ID: <6790000.1091826945@flay>
In-Reply-To: <1091817534.1232.2542.camel@cube>
References: <1091754711.1231.2388.camel@cube> <20040806094037.GB11358@k3.hellgate.ch> <20040806104630.GA17188@holomorphy.com> <20040806120123.GA23081@k3.hellgate.ch> <1091800948.1231.2454.camel@cube> <20040806170832.GA898@k3.hellgate.ch> <1091805296.3547.2522.camel@cube> <283440000.1091825375@flay> <1091817534.1232.2542.camel@cube>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Albert Cahalan <albert@users.sourceforge.net>
Cc: Roger Luethi <rl@hellgate.ch>, William Lee Irwin III <wli@holomorphy.com>, linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Friday, August 06, 2004 14:38:54 -0400 Albert Cahalan <albert@users.sourceforge.net> wrote:

> On Fri, 2004-08-06 at 16:49, Martin J. Bligh wrote:
> 
>> > As long as I can fall back to the old /proc files when truly
>> > radical kernel changes happen, exposure of kernel internals
>> > isn't a serious problem.
>> > 
>> > If I had the DWARF2 data alone, /dev/mem might be enough.
>> > (sadly, "top" would require some major work before I'd trust it)
>> 
>> We did that on PTX ... walking tasklists lockless is a bitch.
> 
> It's fast. Lockless tasklist walking looks easy enough.
> Find the process, grab the data, then find the process
> again. If the process went away, discard the data.

Oh, I know it's fast ... and probably the right thing to do. just hard ;-)
Either that or we come up with some intermediate abstraction that's faster
than /proc.
 
> I guess I'd like to have a /dev/ram-only device, for protection
> against touching device memory (including AGP mem) by mistake.
> It's odd that there doesn't seem to be such a device already.
> Without this, I'd need to re-verify much more often.

I'll make you one if you need it, but it shouldn't be a problem,
I'd think as you're just following pointers, which should all be
valid ...

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

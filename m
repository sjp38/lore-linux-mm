Date: Fri, 06 Aug 2004 13:49:35 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [proc.txt] Fix /proc/pid/statm documentation
Message-ID: <283440000.1091825375@flay>
In-Reply-To: <1091805296.3547.2522.camel@cube>
References: <1091754711.1231.2388.camel@cube> <20040806094037.GB11358@k3.hellgate.ch> <20040806104630.GA17188@holomorphy.com> <20040806120123.GA23081@k3.hellgate.ch> <1091800948.1231.2454.camel@cube> <20040806170832.GA898@k3.hellgate.ch> <1091805296.3547.2522.camel@cube>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Albert Cahalan <albert@users.sourceforge.net>, Roger Luethi <rl@hellgate.ch>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > If it's going to be this dynamic, then just give me DWARF2 debug
>> > info and the raw data. Like this:
>> > 
>> > /proc/DWARF2
>> > /proc/1000/mm_struct
>> > /proc/1000/signal_struct
>> > /proc/1000/sighand_struct
>> > /proc/1000/task/1024/thread_info
>> > /proc/1000/task/1024/task_struct
>> > /proc/1000/task/1024/fs_struct
>> 
>> That's different. The overhead would be prohibitive. Also, this exposes
>> internal kernel structures.
> 
> The overhead? I'm not seeing much, other than the multiple
> files and the very fact that field locations are movable.
> 
> As long as I can fall back to the old /proc files when truly
> radical kernel changes happen, exposure of kernel internals
> isn't a serious problem.
> 
> If I had the DWARF2 data alone, /dev/mem might be enough.
> (sadly, "top" would require some major work before I'd trust it)

We did that on PTX ... walking tasklists lockless is a bitch.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

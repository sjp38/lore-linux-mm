Date: Fri, 6 Aug 2004 09:48:58 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [proc.txt] Fix /proc/pid/statm documentation
Message-ID: <20040806164858.GM17188@holomorphy.com>
References: <1091754711.1231.2388.camel@cube> <20040806094037.GB11358@k3.hellgate.ch> <20040806104630.GA17188@holomorphy.com> <20040806120123.GA23081@k3.hellgate.ch> <1091800948.1231.2454.camel@cube>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1091800948.1231.2454.camel@cube>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Albert Cahalan <albert@users.sf.net>
Cc: Roger Luethi <rl@hellgate.ch>, linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Roger Luethi writes:
>> Most of the current problems with proc are related to tools: They don't
>> like changes and some of them are very sensitive to resource usage
>> (because they may make hundreds of calls per second on typical systems).

On Fri, Aug 06, 2004 at 10:02:28AM -0400, Albert Cahalan wrote:
> Make that 2000 /proc reads per second or more. This is too slow.
> I need to read about 1 million /proc files per second.

This is a truly terrifying prospect. The vfs overheads of manipulating
that much metadata is unthinkably enormous, not to mention the very
real tasklist_lock starvation issues killing boxen dead now.

By any chance could a rate-limited incremental algorithm be used,
at least for top(1)?


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

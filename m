Subject: Re: your mail
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030125231050.GA21095@work.bitmover.com>
References: <Pine.LNX.4.44.0301232104440.10187-100000@dlang.diginsite.com>
	<40475.210.212.228.78.1043384883.webmail@mail.nitc.ac.in>
	<Pine.LNX.4.44.0301232104440.10187-100000@dlang.diginsite.com>
	<3.0.6.32.20030124212935.007fcc10@boo.net>
	<20030125022648.GA13989@work.bitmover.com>
	<m17kctceag.fsf@frodo.biederman.org>
	<20030125231050.GA21095@work.bitmover.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 26 Jan 2003 00:12:03 -0800
Message-Id: <1043568723.4096.2.camel@rth.ninka.net>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Larry McVoy <lm@bitmover.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Jason Papadopoulos <jasonp@boo.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2003-01-25 at 15:10, Larry McVoy wrote:
> All good page coloring implementation do exactly that.  The starting
> index into the page buckets is based on process id.

I think everyone interested in learning more about this
topic should go read the following papers, they were very
helpful when I was fiddling around in this area.

These papers, in turn, reference several others which are
good reads as well.

1) W. L. Lynch, B. K. Bray, and M. J. Flynn. "The effect of page
   allocation on caches". In Micro-25 Conference Proceedings, pages
   222-225, December 1992. 

2) W. Lynch and M. Flynn. "Cache improvements through colored page
   allocation". ACM Transactions on Computer Systems, 1993. Submitted
   for review, 1992. 

3) William L. Lynch. "The Interaction of Virtual Memory and Cache
   Memory". PhD thesis, Stanford University, October
   1993. CSL-TR-93-587.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

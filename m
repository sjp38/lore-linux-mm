From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15183.38493.554937.379169@pizda.ninka.net>
Date: Fri, 13 Jul 2001 17:46:21 -0700 (PDT)
Subject: Re: [PATCH] VM statistics code
In-Reply-To: <20010714123141.A6119@weta.f00f.org>
References: <Pine.LNX.4.21.0107131946410.3892-100000@freak.distro.conectiva>
	<20010714123141.A6119@weta.f00f.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wedgwood <cw@f00f.org>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chris Wedgwood writes:
 > On Fri, Jul 13, 2001 at 07:53:12PM -0300, Marcelo Tosatti wrote:
 > 
 >     Maybe. Personally I don't really care about the way we are doing
 >     this, as long as I can get the information. I can add /proc/vmstat
 >     easily if needed...
 > 
 > How about something under advance kernel hacking options of wherever
 > the sysrq options is? (and profiling used to live, before it was
 > always there), or, since the code is rather small, we could perhaps
 > always have this available.

I personally feel that it is imperative to have some kind of "lower
level" statistics available by default in the VM.  It would
undoubtedly save some head scratching for most bug reports.

We have all of this kind of stuff in the networking, because the SNMP
mibs require us to keep track of the information.  I can say for
certain that several bugs were found quickly because we were able to
notice anomalies in the events being triggered on the person's
machine.

There is a bit of a performance issue, since our VM is decently
threaded.  That can be solved with per-cpu statistics blocks like
the networking uses.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

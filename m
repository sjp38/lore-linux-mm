Date: Sat, 14 Jul 2001 12:31:41 +1200
From: Chris Wedgwood <cw@f00f.org>
Subject: Re: [PATCH] VM statistics code
Message-ID: <20010714123141.A6119@weta.f00f.org>
References: <Pine.LNX.4.21.0107131946410.3892-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0107131946410.3892-100000@freak.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 13, 2001 at 07:53:12PM -0300, Marcelo Tosatti wrote:

    Maybe. Personally I don't really care about the way we are doing
    this, as long as I can get the information. I can add /proc/vmstat
    easily if needed...

How about something under advance kernel hacking options of wherever
the sysrq options is? (and profiling used to live, before it was
always there), or, since the code is rather small, we could perhaps
always have this available.

    Well, I don't want to include this stuff on the stock vmstat code
    right now. I've done an ugly hack in vmstat.c to get the thing to
    work and thats it.

Fair enough, but the comment "please apply" makes me nervous then :)



  --cw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

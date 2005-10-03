Date: Sun, 2 Oct 2005 22:33:52 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
Message-Id: <20051002223352.6d21a8bc.pj@sgi.com>
In-Reply-To: <aec7e5c30510022205o770b6335o96d9a9d9cc5d7397@mail.gmail.com>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
	<1128093825.6145.26.camel@localhost>
	<20051002202157.7b54253d.pj@sgi.com>
	<aec7e5c30510022205o770b6335o96d9a9d9cc5d7397@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: haveblue@us.ibm.com, magnus@valinux.co.jp, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Magnus wrote:
> So, Paul, please let me know if you prefer SMP || NUMA or no
> depencencies in the Kconfig.

In theory, I prefer none.  But the devil is in the details here,
and I really don't care that much.

So pick whichever you prefer, or whichever provides the nicest
looking code or patch, or flip a coin ;).

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Sun, 6 Jul 2003 20:22:39 -0700
From: "Randy.Dunlap" <randy.dunlap@verizon.net>
Subject: Re: kgdb-irq=3 kgdb-io=0x038f
Message-Id: <20030706202239.6ed7c5bb.randy.dunlap@verizon.net>
In-Reply-To: <20030706124720.038c7b71.rddunlap@osdl.org>
References: <20030706124720.038c7b71.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ecashin@uga.edu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

| Hi.  Has anyone ever tried making kernel boot options to set the kgdb
| serial settings instead of setting them statically at .config
| generation?
| 
| If not, would that be an easy thing to do?

Looks doable, unless I'm missing some small quirk.

I haven't seen such a patch.  However, ISTM that most (of my)
debugging is in an almost static environment anyway.

If you are interested in trying to make such a patch and need some
help, I'll work on it with you.

--
~Randy
~ http://developer.osdl.org/rddunlap/ ~ http://www.xenotime.net/linux/ ~
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

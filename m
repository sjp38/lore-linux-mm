Date: Tue, 04 Jan 2005 14:03:48 -0800
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Re: page migration
In-Reply-To: <1104776733.25994.11.camel@localhost>
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost>
Message-Id: <20050104133051.569E.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello Ray-san.

> > I've been unable to get (either) memory hotplug patch to compile.  It won't
> > compile for Altix at all, because Altix requires NUMA.  I tried it on a
> > Pentium machine, but apparently I didn't grab the correct config.
> 
> Hmmm.  Did you check the configs here?
> 
> 	http://sr71.net/patches/2.6.10/2.6.10-rc2-mm4-mhp3/configs/

CONFIG_NUMA with memory hotplug is disabled on -mhp3,
because some functions of memory hotplug are not defined yet and
some works like pgdat allocation are necessary.
.
I posted patches for them before holidays to LHMS.
http://sourceforge.net/mailarchive/forum.php?forum_id=223&max_rows=25&style=ultimate&viewmonth=200412

It is still for IA32. But, I would like to start works for IA64.
I guess it won't be duplication against your works.
But If you find something wrong, please let me know.

Bye.

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

From: Andi Kleen <ak@suse.de>
Subject: Re: Making PCI Memory Cachable
Date: Sat, 9 Dec 2006 22:36:21 +0100
References: <20061209143341.90545.qmail@web52308.mail.yahoo.com>
In-Reply-To: <20061209143341.90545.qmail@web52308.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200612092236.21882.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fusco <fusco_john@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> BTW, why won't cache coherency protocol work over PCI? 

It's not supported by the hardware. There is a initiative from Intel
to support it in the future over PCI-Express, but that's some time
off and still most devices won't support it.

> It has commands to support this, such as "memory read line" and "memory write line". Is it that Linux does not allow memory outside of RAM to be cacheable? 

A proper cache coherency protocol is much more complicated. It's a relatively
complex state machine (MESI). Details vary by CPUs.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

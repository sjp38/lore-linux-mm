Message-ID: <20010315062806.24508.qmail@nwcst340.netaddress.usa.net>
Date: 14 Mar 2001 23:28:06 MST
From: Jawad Qureshi <qureshi_jawad@usa.net>
Subject: 
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

I am facing some problems with the pci. I have two questions about Pci.
First is that 
1-how one can explicitly specify to brust on the pci device;
2-We have a custom made pci card . The problem is that the transfer on this
card is slow. I am making 40 double word transfers from the fifoes on the
board to the memory. The pci card does not allow brusts. These transfers are
taking almost 32us. Can any body tell why this much time is taking place.

Thanks in Advance 
Jawad


____________________________________________________________________
Get free email and a permanent address at http://www.netaddress.com/?N=1
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

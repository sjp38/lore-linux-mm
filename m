Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id KAA00006
	for <linux-mm@kvack.org>; Thu, 17 Oct 2002 10:22:08 -0700 (PDT)
Message-ID: <3DAEF1BE.6ECC2A41@digeo.com>
Date: Thu, 17 Oct 2002 10:22:06 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.43-mm2 gets network connection stuck
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com> <20021013223332.GA870@hswn.dk> <20021016183907.B29405@in.ibm.com> <20021016154943.GA13695@hswn.dk> <20021017200843.D29405@in.ibm.com> <20021017181439.A8089@turing.fb12.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sebastian Benoit <benoit-lists@fb12.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sebastian Benoit wrote:
> 
> Hi,
> 
> funny problem w. 2.5.43-mm2:
> 

I saw something like that last night as well.  One ssh session
(sshd running on 2.5.43-mm2) just stopped doing anything.

The -mm patches always include Linus's current -bk snapshot,
and 2.5.43-mm2 has a lot of networking changes:

 net/core/dst.c                           |   25 
 net/ipv4/af_inet.c                       |   17 
 net/ipv4/icmp.c                          |    4 
 net/ipv4/ip_output.c                     |  880 ++++++++--
 net/ipv4/ip_proc.c                       |   74 
 net/ipv4/ip_sockglue.c                   |    4 
 net/ipv4/raw.c                           |    7 
 net/ipv4/tcp.c                           |   49 
 net/ipv4/tcp_ipv4.c                      |    6 
 net/ipv4/tcp_minisocks.c                 |   10 
 net/ipv4/udp.c                           |  296 +++

Looks like something may have broken there.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

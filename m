Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with SMTP id A635FD0D7
	for <linux-mm@kvack.org>; Thu, 22 Jun 2000 20:52:19 -0400 (EDT)
From: Ed Tomlinson <tomlins@cam.org>
Reply-To: tomlins@cam.org
Subject: Re: [RFC] RSS guarantees and limits
Date: Thu, 22 Jun 2000 20:49:41 -0400
Content-Type: text/plain
References: <Pine.LNX.4.21.0006222022420.1137-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.21.0006222022420.1137-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Message-Id: <00062220521900.11608@oscar>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Just wondering what will happen with java applications?  These beasts
typically have working sets of 16M or more and use 10-20 threads.  When
using native threads linux sees each one as a process.  They all share 
the same memory though.

-- 
Ed Tomlinson <tomlins@cam.org>
http://www.cam.org/~tomlins/njpipes.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

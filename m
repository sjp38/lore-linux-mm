Received: from northrelay01.pok.ibm.com (northrelay01.pok.ibm.com [9.117.200.21])
	by e2.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id KAA23324
	for <linux-mm@kvack.org>; Fri, 23 Jun 2000 10:00:11 -0400
From: frankeh@us.ibm.com
Received: from D51MTA03.pok.ibm.com (d51mta03.pok.ibm.com [9.117.200.31])
	by northrelay01.pok.ibm.com (8.8.8m3/NCO v2.07) with SMTP id KAA70126
	for <linux-mm@kvack.org>; Fri, 23 Jun 2000 10:02:03 -0400
Message-ID: <85256907.004D1292.00@D51MTA03.pok.ibm.com>
Date: Fri, 23 Jun 2000 10:01:14 -0400
Subject: Re: [RFC] RSS guarantees and limits
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

How is shared memory accounted for?

Options are:
(a) Creator is charged
(b) prorated per number of users

any others options come to mind ?

-- Hubertus Franke
    IBM T.J.Watson Research Center


Rik van Riel <riel@conectiva.com.br>@kvack.org on 06/23/2000 10:15:46 AM

Sent by:  owner-linux-mm@kvack.org


To:   Ed Tomlinson <tomlins@cam.org>
cc:   linux-mm@kvack.org
Subject:  Re: [RFC] RSS guarantees and limits



On Thu, 22 Jun 2000, Ed Tomlinson wrote:

> Just wondering what will happen with java applications?  These
> beasts typically have working sets of 16M or more and use 10-20
> threads.  When using native threads linux sees each one as a
> process.  They all share the same memory though.

Ahh, but these limits are of course applied per _MM_, not
per thread ;)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/          http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

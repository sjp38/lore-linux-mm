From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.43-mm1: KDE (3.1 beta2) do not start anymore
Reply-To: tomlins@cam.org
Date: Wed, 16 Oct 2002 18:50:43 -0400
References: <200210162327.53701.Dieter.Nuetzel@hamburg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8Bit
Message-Id: <20021016225043.4A3732FBBA@oscar.casa.dyndns.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dieter =?ISO-8859-1?Q?N=FCtzel?= <Dieter.Nuetzel@hamburg.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dieter Nutzel wrote:

> Nothing in the logs.
> But maybe (short before) sound initialization.
> Could it be "shared page table" related, too?
> 
> W'll try that tomorrow.

Kde 3.0 has never been able to start here when shared page tables have
been enabled in an mm kernel.  Still some cleanups and debugging to do 
it would seem.

Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Thu, 9 Aug 2001 00:49:10 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Changes in vm_operations_struct 2.2.x => 2.4.x
Message-ID: <20010809004910.C1200@nightmaster.csn.tu-chemnitz.de>
References: <3B6A5A52.73D0DC12@scs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B6A5A52.73D0DC12@scs.ch>; from maletinsky@scs.ch on Fri, Aug 03, 2001 at 10:01:22AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 03, 2001 at 10:01:22AM +0200, Martin Maletinsky wrote:
> Does anyone know the reason why the number of operations in
> vm_operation_struct has been reduced?

Al Viro reduced it, because nobody used them for several years.
Nobody complained after removing them, also.

Maybe you can explain more, what you try to do in your module and
people can help you.

Regards

Ingo Oeser
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

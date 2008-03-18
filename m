Date: Tue, 18 Mar 2008 1:58:59 -0000
From: "Rodrigo Rubira Branco (BSDaemon)" <rodrigo@kernelhacking.com>
Reply-to: "Rodrigo Rubira Branco (BSDaemon)" <rodrigo@kernelhacking.com>
Subject: Re: ebizzy performance with different allocators
Content-Transfer-Encoding: 7BIT
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Message-Id: <20080318045859.E89208BD87@mail.fjaunet.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valerie Henson <val@vahconsulting.com>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: opensource@google.com, Jakub Jelinek <jakub@redhat.com>, "linux-mm@kvack.org"@fjaunet.com.br, Rodrigo Rubira Branco BSDaemon <rodrigo@kernelhacking.com>
List-ID: <linux-mm.kvack.org>

Hello,

> If you use the &quot;-M&quot; option to ebizzy, it will use mallopt() to
turn
> off mmap()'d allocations entirely. (It'd be nice to have command line
> knobs for all the mallopt() tuning options, actually.)

I'll work on it...



cya,


Rodrigo (BSDaemon).

--
http://www.kernelhacking.com/rodrigo

Kernel Hacking: If i really know, i can hack

GPG KeyID: 1FCEDEA1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

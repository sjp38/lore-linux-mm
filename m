Date: Tue, 3 Apr 2001 11:44:15 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: memory mgmt/tuning for diskless machines
Message-ID: <Pine.LNX.4.30.0104031116450.406-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2001, Marcelo Tosatti wrote:

> > So... it occured to me I could tune this with /proc/sys/vm/freepages -
> > but now I find that it's read-only,
> It should work. Are you sure you're trying to change it as root ?
> Which kernel version are you using ?

It doesn't work since 2.4.0-test9
	http://www.uwsg.iu.edu/hypermail/linux/kernel/0009.2/0129.html

    Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

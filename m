Date: Tue, 29 Apr 2003 13:28:29 +0200
From: Jan Hudec <bulb@ucw.cz>
Subject: Re: questions on swapping
Message-ID: <20030429112829.GD668@vagabond>
References: <OF8E0064D4.ECA596BD-ON65256D17.003D6ECB@celetron.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF8E0064D4.ECA596BD-ON65256D17.003D6ECB@celetron.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heerappa Hunje <hunjeh@celetron.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2003 at 04:52:36PM +0530, Heerappa Hunje wrote:
> Thanks for the information, well i have following difficulties.
> 1. How to handle/write the Bottom Half part of Interrupt for Device Drivers
> 2. If any error, then the messages during the running of Device Driver
> modules where(in which file) they are written by Kernel, or we have to
> specify the location/Pathname of file during the implimentation.

Kernel prints messages using the printk function. It writes them to the
active console and makes them available via a magic file in /proc
filesystem where they are picked by klogd and passed to syslogd.

printk is specially crafted so that it can be called from any point of
kernel (including interrupt context).

-------------------------------------------------------------------------------
						 Jan 'Bulb' Hudec <bulb@ucw.cz>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

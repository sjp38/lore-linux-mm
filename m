Date: Tue, 29 Apr 2003 08:24:31 -0700
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: questions on swapping
Message-Id: <20030429082431.21679c0f.rddunlap@osdl.org>
In-Reply-To: <20030429112829.GD668@vagabond>
References: <OF8E0064D4.ECA596BD-ON65256D17.003D6ECB@celetron.com>
	<20030429112829.GD668@vagabond>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Hudec <bulb@ucw.cz>
Cc: hunjeh@celetron.com, kernelnewbies@nl.linux.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Tue, 29 Apr 2003 13:28:29 +0200 Jan Hudec <bulb@ucw.cz> wrote:

| On Tue, Apr 29, 2003 at 04:52:36PM +0530, Heerappa Hunje wrote:
| > Thanks for the information, well i have following difficulties.
| > 1. How to handle/write the Bottom Half part of Interrupt for Device Drivers
| > 2. If any error, then the messages during the running of Device Driver
| > modules where(in which file) they are written by Kernel, or we have to
| > specify the location/Pathname of file during the implimentation.
| 
| Kernel prints messages using the printk function. It writes them to the
| active console and makes them available via a magic file in /proc
| filesystem where they are picked by klogd and passed to syslogd.

Try this paragraph instead:
Kernel prints messages using the printk function.  printk queues messages
to a ring buffer.  Messages are pulled from the ring buffer by syslog
or klog using the syslog system call.
Console messages are printed to all registered console output methods,
such as ones for the video console, serial console, printer, etc.

(no magic /proc file)

| printk is specially crafted so that it can be called from any point of
| kernel (including interrupt context).

--
~Randy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

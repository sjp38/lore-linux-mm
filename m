Date: Tue, 8 Apr 2003 08:31:53 -0700
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: 2.5.67-mm1
Message-Id: <20030408083153.5dec0d0e.rddunlap@osdl.org>
In-Reply-To: <200304080917.15648.tomlins@cam.org>
References: <20030408042239.053e1d23.akpm@digeo.com>
	<200304080917.15648.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: akpm@digeo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Apr 2003 09:17:15 -0400 Ed Tomlinson <tomlins@cam.org> wrote:

| Hi,
| 
| This does not boot here.  I loop with the following message. 
| 
| i8042.c: Can't get irq 12 for AUX, unregistering the port.
| 
| irq 12 is used (correctly) by my 20267 ide card.  My mouse is
| usb and AUX is not used.
| 
| Ideas?

I guess that's due to my early kbd init patch.
So why do you have i8042 configured into your kernel?

The loop doesn't terminate?  Do you get the same message (above)
over and over again?

--
~Randy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

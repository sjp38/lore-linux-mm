From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.67-mm1
Date: Tue, 8 Apr 2003 12:18:22 -0400
References: <20030408042239.053e1d23.akpm@digeo.com> <200304080917.15648.tomlins@cam.org> <20030408083153.5dec0d0e.rddunlap@osdl.org>
In-Reply-To: <20030408083153.5dec0d0e.rddunlap@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200304081218.22598.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: akpm@digeo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On April 8, 2003 11:31 am, Randy.Dunlap wrote:
> | This does not boot here.  I loop with the following message.
> |
> | i8042.c: Can't get irq 12 for AUX, unregistering the port.
> |
> | irq 12 is used (correctly) by my 20267 ide card.  My mouse is
> | usb and AUX is not used.
> |
> | Ideas?
>
> I guess that's due to my early kbd init patch.

Just to confirm, removing the above patch lets me 
boot just fine.

Thanks
Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

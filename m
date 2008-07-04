Message-ID: <486E2F68.2000707@garzik.org>
Date: Fri, 04 Jul 2008 10:10:48 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>	 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <486CC440.9030909@garzik.org>	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>	 <s5hmykxc3ja.wl%tiwai@suse.de>	 <1215177471.10393.753.camel@pmac.infradead.org>	 <s5hej69lqzk.wl%tiwai@suse.de>  <486E28BB.1030205@garzik.org> <1215179126.10393.771.camel@pmac.infradead.org>
In-Reply-To: <1215179126.10393.771.camel@pmac.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Takashi Iwai <tiwai@suse.de>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Woodhouse wrote:
> On Fri, 2008-07-04 at 09:42 -0400, Jeff Garzik wrote:
>> mkinitrd and similar scripts must be updated, so that drivers that 
>> worked prior to dwmw2's changes will continue to work after dwmw2's
>> changes.
> 
>> If you fail to update some script somewhere, then the driver will be 
>> copied into the initramfs, but not the firmware, with obvious results.
> 
> No, mkinitrd works fine, because a whole boatload of drivers _already_
> require it to work that way and have done for a long time.
> 
> Either you are severely mistaken, or you are being deliberately
> misleading.

It is a fact that mkinitrd, today, is unaware of your new system of 
obtaining firmware from the kernel source[or build] tree.

Certainly it is aware of the need to copy firmware in general, but that 
doesn't change the fact that the tg3 firmware will not make it into 
initramfs, without additional steps taken.

So, no, it doesn't "work fine" -- the firmware doesn't make it into the 
initramfs.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

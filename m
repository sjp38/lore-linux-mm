Subject: Re: questions on swapping
Message-ID: <OF961A2D5A.E4FF4CB2-ON65256D17.0049CB5E@celetron.com>
From: "Heerappa Hunje" <hunjeh@celetron.com>
Date: Tue, 29 Apr 2003 18:58:42 +0530
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Hudec <bulb@ucw.cz>
Cc: Jan 'Bulb' Hudec <bulb@vagabond.cybernet.cz>, kernelnewbies@nl.linux.org, linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi,

Please let me know what are all standard criteria to be followed when
writing the Bottom Half Interrupt handlers for Device Drivers.

Thanks in Advance

Thanks n Regards
Heerappa



|---------+---------------------------->
|         |           Jan Hudec        |
|         |           <bulb@ucw.cz>    |
|         |           Sent by: Jan     |
|         |           'Bulb' Hudec     |
|         |           <bulb@vagabond.cy|
|         |           bernet.cz>       |
|         |                            |
|         |                            |
|         |           04/29/2003 04:58 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >------------------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                              |
  |       To:       Heerappa Hunje <hunjeh@celetron.com>                                                                         |
  |       cc:       kernelnewbies@nl.linux.org, linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>                   |
  |       Subject:  Re: questions on swapping                                                                                    |
  >------------------------------------------------------------------------------------------------------------------------------|




On Tue, Apr 29, 2003 at 04:52:36PM +0530, Heerappa Hunje wrote:
> Thanks for the information, well i have following difficulties.
> 1. How to handle/write the Bottom Half part of Interrupt for Device
Drivers
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

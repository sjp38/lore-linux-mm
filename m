Subject: Re: questions on swapping
Message-ID: <OF8E0064D4.ECA596BD-ON65256D17.003D6ECB@celetron.com>
From: "Heerappa Hunje" <hunjeh@celetron.com>
Date: Tue, 29 Apr 2003 16:52:36 +0530
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Hudec <bulb@ucw.cz>
Cc: Jan 'Bulb' Hudec <bulb@vagabond.cybernet.cz>, kernelnewbies@nl.linux.org, linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Dear Jan Hudec.

Thanks for the information, well i have following difficulties.
1. How to handle/write the Bottom Half part of Interrupt for Device Drivers
2. If any error, then the messages during the running of Device Driver
modules where(in which file) they are written by Kernel, or we have to
specify the location/Pathname of file during the implimentation.

Thanks in advance.

Thanks n Regards
Heerappa.



|---------+---------------------------->
|         |           Jan Hudec        |
|         |           <bulb@ucw.cz>    |
|         |           Sent by: Jan     |
|         |           'Bulb' Hudec     |
|         |           <bulb@vagabond.cy|
|         |           bernet.cz>       |
|         |                            |
|         |                            |
|         |           04/29/2003 01:33 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >------------------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                              |
  |       To:       Heerappa Hunje <hunjeh@celetron.com>                                                                         |
  |       cc:       William Lee Irwin III <wli@holomorphy.com>, kernelnewbies@nl.linux.org, linux-mm@kvack.org                   |
  |       Subject:  Re: questions on swapping                                                                                    |
  >------------------------------------------------------------------------------------------------------------------------------|




On Mon, Apr 28, 2003 at 03:07:08PM +0530, Heerappa Hunje wrote:
> Let me know how much of memory a system adminstrator can configure for
> buffering mechanism out 128MB/256MB  or it will be choosen by the Linux
> itself.

Buffers are rather transient stuff during IO operations. Kernel will
allocate memory for them as they are needed.

All memory, that is not used by kernel or applications is used for
caching files (page cache). No need to configure that either.

-------------------------------------------------------------------------------


Jan 'Bulb' Hudec <bulb@ucw.cz>





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Subject: Re: questions on swapping
Message-ID: <OF48B89A80.1B070B4E-ON65256D16.002A0894@celetron.com>
From: "Heerappa Hunje" <hunjeh@celetron.com>
Date: Mon, 28 Apr 2003 13:24:17 +0530
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dear William,

Thanks for the reply and information, well i wanted to know  that how can i
see the source code of linux when iam working on linux being in the root,
what pathname name should i type to get to the source code file of linux.

2. if i have the device driver module's source code written for perticular
device than  where should i store it, so that it will support to my device
whenever any user seeks it.

3. During installation of linux, what if i assign the swapping space4 times
of my present memory size OR less than the present memory size. I mean will
it have any problems in system performance in both the cases.

4. what command should i type to know the version of my present OS.

Please Suggest me

Thanks n Regards
Heerappa




|---------+---------------------------->
|         |           William Lee Irwin|
|         |           III              |
|         |           <wli@holomorphy.c|
|         |           om>              |
|         |                            |
|         |           04/28/2003 12:56 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >------------------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                              |
  |       To:       Heerappa Hunje <hunjeh@celetron.com>                                                                         |
  |       cc:       linux-mm@kvack.org, kernelnewbies@nl.linux.org                                                               |
  |       Subject:  Re: questions on swapping                                                                                    |
  >------------------------------------------------------------------------------------------------------------------------------|




On Mon, Apr 28, 2003 at 12:46:15PM +0530, Heerappa Hunje wrote:
> 1. I have problem in locating the source code of linux operating system
> because i dont know in which path it is kept. Pls suggest me the
pathname.

ftp://ftp.kernel.org/pub/linux/kernel/v2.5/
             and
ftp://ftp.kernel.org/pub/linux/kernel/v2.4/

for the less adventurous


On Mon, Apr 28, 2003 at 12:46:15PM +0530, Heerappa Hunje wrote:
> 2. let me know the different ways to connect the device drivers module to
> the kernel.

This is a bit too general to answer at all.


On Mon, Apr 28, 2003 at 12:46:15PM +0530, Heerappa Hunje wrote:
> 3. let me know where actually the space for SWAPPING, BUFFERS  are
> allocated. i mean whether they are in RAM Memory or Hard disk drive.

Buffers are in RAM, swap is on-disk.


-- wli





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

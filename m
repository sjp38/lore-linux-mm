Subject: Re: questions on swapping
Message-ID: <OF7CE27550.1251F377-ON65256D16.00335C8F@celetron.com>
From: "Heerappa Hunje" <hunjeh@celetron.com>
Date: Mon, 28 Apr 2003 15:02:40 +0530
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Babu Dhandapani <babud@npd.hcltech.com>
Cc: linux-mm@kvack.org, kernelnewbies@nl.linux.org, Aniruddha_Patwardhan@bmc.com
List-ID: <linux-mm.kvack.org>

Hi Babu n Anirudh,
Thanks for the reply,

will the driver will get executed if i put my source code of driver in the
path /usr/src/linux/drivers/        or else should i put the makefile in
the same path.


Thanks in advance.


Thanks and Regards
Heerappa.



|---------+---------------------------->
|         |           Babu Dhandapani  |
|         |           <babud@npd.hcltec|
|         |           h.com>           |
|         |                            |
|         |           04/28/2003 01:37 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >------------------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                              |
  |       To:       Heerappa Hunje <hunjeh@celetron.com>                                                                         |
  |       cc:                                                                                                                    |
  |       Subject:  Re: questions on swapping                                                                                    |
  >------------------------------------------------------------------------------------------------------------------------------|




Hi  Heerappa,
    I will try to answer to your queries...answers are inline .

      Thanks for the reply and information, well i wanted to know  that how
      can i
      see the source code of linux when iam working on linux being in the
      root,
      what pathname name should i type to get to the source code file of
      linux.
the source code will be in the path /usr/src/linux/


      2. if i have the device driver module's source code written for
      perticular
      device than  where should i store it, so that it will support to my
      device
      whenever any user seeks it.
you can put your driver's code in the path /usr/src/linux/drivers/


      3. During installation of linux, what if i assign the swapping space4
      times
      of my present memory size OR less than the present memory size. I
      mean will
      it have any problems in system performance in both the cases.
if your swap sapce is more means your system may put good performance at
high loads
the vice versa also holds good i think...


      4. what command should i type to know the version of my present OS.
uname -a

Regds,
Babu


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
        >
      ------------------------------------------------------------------------------------------------------------------------------|

        |
      |
        |       To:       Heerappa Hunje <hunjeh@celetron.com>
      |
        |       cc:       linux-mm@kvack.org, kernelnewbies@nl.linux.org
      |
        |       Subject:  Re: questions on swapping
      |
        >
      ------------------------------------------------------------------------------------------------------------------------------|





      On Mon, Apr 28, 2003 at 12:46:15PM +0530, Heerappa Hunje wrote:
            1. I have problem in locating the source code of linux
            operating system
            because i dont know in which path it is kept. Pls suggest me
            the
      pathname.

      ftp://ftp.kernel.org/pub/linux/kernel/v2.5/
                   and
      ftp://ftp.kernel.org/pub/linux/kernel/v2.4/

      for the less adventurous


      On Mon, Apr 28, 2003 at 12:46:15PM +0530, Heerappa Hunje wrote:
            2. let me know the different ways to connect the device drivers
            module to
            the kernel.

      This is a bit too general to answer at all.


      On Mon, Apr 28, 2003 at 12:46:15PM +0530, Heerappa Hunje wrote:
            3. let me know where actually the space for SWAPPING, BUFFERS
            are
            allocated. i mean whether they are in RAM Memory or Hard disk
            drive.

      Buffers are in RAM, swap is on-disk.


      -- wli





      --
      To unsubscribe, send a message with 'unsubscribe linux-mm' in
      the body to majordomo@kvack.org.  For more info on Linux MM,
      see: http://www.linux-mm.org/ .
      Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

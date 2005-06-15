Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5FMwqmD700336
	for <linux-mm@kvack.org>; Wed, 15 Jun 2005 18:58:52 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5FMwm0E162982
	for <linux-mm@kvack.org>; Wed, 15 Jun 2005 16:58:52 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5FMwm37032158
	for <linux-mm@kvack.org>; Wed, 15 Jun 2005 16:58:48 -0600
Subject: RE: 2.6.12-rc6-mm1 & 2K lun testing
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <200506152139.j5FLd3g26510@unix-os.sc.intel.com>
References: <200506152139.j5FLd3g26510@unix-os.sc.intel.com>
Content-Type: text/plain
Message-Id: <1118874915.4301.461.camel@dyn9047017072.beaverton.ibm.com>
Mime-Version: 1.0
Date: 15 Jun 2005 15:35:15 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-06-15 at 14:39, Chen, Kenneth W wrote:
> Badari Pulavarty wrote on Wednesday, June 15, 2005 10:36 AM
> > I sniff tested 2K lun support with 2.6.12-rc6-mm1 on
> > my AMD64 box. I had to tweak qlogic driver and
> > scsi_scan.c to see all the luns.
> > 
> > (2.6.12-rc6 doesn't see all the LUNS due to max_lun
> > issue - which is fixed in scsi-git tree).
> > 
> > Test 1:
> > 	run dds on all 2048 "raw" devices - worked
> > great. No issues.
> 
> Just curious, how many physical disks do you have for this test?
> 

2048 luns are created using NetApp FAS 270C - which has 28 drives.
I am accessing the luns through fiber channel.


Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

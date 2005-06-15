Message-Id: <200506152139.j5FLd3g26510@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: 2.6.12-rc6-mm1 & 2K lun testing
Date: Wed, 15 Jun 2005 14:39:03 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Badari Pulavarty' <pbadari@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote on Wednesday, June 15, 2005 10:36 AM
> I sniff tested 2K lun support with 2.6.12-rc6-mm1 on
> my AMD64 box. I had to tweak qlogic driver and
> scsi_scan.c to see all the luns.
> 
> (2.6.12-rc6 doesn't see all the LUNS due to max_lun
> issue - which is fixed in scsi-git tree).
> 
> Test 1:
> 	run dds on all 2048 "raw" devices - worked
> great. No issues.

Just curious, how many physical disks do you have for this test?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

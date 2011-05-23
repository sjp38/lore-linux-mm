Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 34CC26B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 14:33:04 -0400 (EDT)
Received: from mail.mediafire.com (unknown [10.9.180.5])
	by mi11 (SG) with ESMTP id 4ddaa85d.498e.22800f
	for <linux-mm@kvack.org>; Mon, 23 May 2011 13:33:01 -0500 (CST)
Received: from [10.10.23.246]
        by mail.mediafire.com (IceWarp 10.3.0) with ESMTP (SSL) id GXE51502
        for <linux-mm@kvack.org>; Mon, 23 May 2011 13:33:02 -0500
Subject: PROBLEM:  Kernel panics on do_raw_spin_lock()
From: Bryan Christ <bryan@mediafire.com>
Reply-To: bryan@mediafire.com
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 23 May 2011 13:33:00 -0500
Message-ID: <1306175580.2481.16.camel@tuxdev64>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Kernel seems to frequently panic with RIP at do_raw_spin_lock().  I
assume this might be vma related since the trace often implicates
vma_merge() and friends.

Linux version 2.6.38.6-26.rc1.fc14.x86_64

Module                  Size  Used by
xfs                   700603  5 
exportfs                3440  1 xfs
p4_clockmod             4486  0 
freq_table              3963  1 p4_clockmod
speedstep_lib           4847  1 p4_clockmod
ipv6                  288342  26 
iTCO_wdt               11592  0 
shpchp                 24810  0 
iTCO_vendor_support     2634  1 iTCO_wdt
serio_raw               4442  0 
i2c_i801                9293  0 
i5000_edac              8340  0 
edac_core              41090  3 i5000_edac
i5k_amb                 4882  0 
ioatdma                45294  9 
e1000e                200202  0 
ppdev                   7868  0 
parport_pc             21303  0 
parport                31338  2 ppdev,parport_pc
microcode              18276  0 
dca                     5854  1 ioatdma
ext2                   59952  1 
usb_storage            45607  1 
uas                     7768  0 
radeon                696138  1 
ttm                    55897  1 radeon
drm_kms_helper         27729  1 radeon
drm                   189462  3 radeon,ttm,drm_kms_helper
i2c_algo_bit            5062  1 radeon
i2c_core               25745  5
i2c_i801,radeon,drm_kms_helper,drm,i2c_algo_bit

Screenshots of panic:

http://www.mediafire.com/imageview.php?quickkey=hnd1dedna9bed65
http://www.mediafire.com/imageview.php?quickkey=n86366d44i7mlx4
http://www.mediafire.com/imageview.php?quickkey=0sgzfd91dvl3jhl
http://www.mediafire.com/imageview.php?quickkey=zwly9x5c4zg28dn

I will be glad to provide as much information as I can.  Just let me
know what is needed.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

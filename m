Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0863E6B0092
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 16:30:08 -0400 (EDT)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1PD112-0001St-5X
	for linux-mm@kvack.org; Mon, 01 Nov 2010 21:30:04 +0100
Received: from 178-14-100.dynamic.cyta.gr ([178.59.14.100])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 21:30:04 +0100
Received: from jimis by 178-14-100.dynamic.cyta.gr with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 21:30:04 +0100
From: Dimitrios Apostolou <jimis@gmx.net>
Subject: Re: 2.6.36 io bring the system to its knees
Date: Mon, 1 Nov 2010 01:09:34 +0000 (UTC)
Message-ID: <ial40e$jpj$1@dough.gmane.org>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
	<AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
	<AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
	<AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
	<20101031012224.GA8007@localhost> <20101031015132.GA10086@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello, 

On Sun, 31 Oct 2010 09:51:32 +0800, Wu Fengguang wrote:
> It may also help to lower the dirty ratio.
> 
> echo 5 > /proc/sys/vm/dirty_ratio
> 
> Memory pressure + heavy write can easily hurt responsiveness.
> 
> - eats up to 20% (the default value for dirty_ratio) memory with dirty
>   pages and hence increase the memory pressure and number of swap IO

My experience has been different with that. Wouldn't it make more sense 
to _increase_ dirty_ratio (to 50 lets say) and at the same time decrease 
dirty_background_ratio? That way writing to disk starts early, but the 
related apps stall waiting for I/O only when dirty_ratio is reached.


Thanks, 
Dimitris

> 
> - the file copy makes the device write congested and hence makes
>   pageout() easily blocked in get_request_wait()
> 
> As a result every application may be slowed down by the heavy swap IO
> when page fault as well as being blocked when allocating memory (which
> may go into direct reclaim and then call pageout()).
> 
> Thanks,
> Fengguang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

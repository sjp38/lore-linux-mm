Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id E57136B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 14:26:28 -0500 (EST)
Received: by mail-qa0-f50.google.com with SMTP id cm18so6753333qab.37
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 11:26:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 8si8384478qav.114.2014.01.31.11.26.28
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 11:26:28 -0800 (PST)
Date: Fri, 31 Jan 2014 14:26:17 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [LSF/MM TOPIC] Fixing large block devices on 32 bit
Message-ID: <20140131192617.GA14098@redhat.com>
References: <1391194978.2172.20.camel@dabdike.int.hansenpartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391194978.2172.20.camel@dabdike.int.hansenpartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-scsi <linux-scsi@vger.kernel.org>, linux-ide <linux-ide@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Fri, Jan 31, 2014 at 11:02:58AM -0800, James Bottomley wrote:
 
 > it will only be a couple of years before 16TB devices are
 > available.  By then, I bet that most arm (and other exotic CPU) Linux
 > based personal file servers are still going to be 32 bit, so they're not
 > going to be able to take this generation (or beyond) of drives. 
 > 
 >      1. Try to pretend that CONFIG_LBDAF is supposed to cap out at 16TB
 >         and there's nothing we can do about it ... this won't be at all
 >         popular with arm based file server manufacturers.

Some of the higher end home-NAS's have already moved from arm/ppc -> x86_64[1]
Unless ARM64 starts appearing at a low enough price point, I wouldn't be 
surprised to see the smaller vendors do a similar move just to stay competitive.
(probably while keeping 'legacy' product lines for a while at a cheaper pricepoint
 that won't take bigger disks).

	Dave

[1] http://forum.synology.com/wiki/index.php/What_kind_of_CPU_does_my_NAS_have

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

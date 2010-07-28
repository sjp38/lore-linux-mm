Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4016B02B0
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 03:37:25 -0400 (EDT)
Subject: Re: [Xen-devel] [PATCH] GSoC 2010 - Memory hotplug support for Xen
 guests - fully working version
From: Vasiliy G Tolstov <v.tolstov@selfip.ru>
Reply-To: v.tolstov@selfip.ru
In-Reply-To: <20100727004113.GA3714@router-fw-old.local.net-space.pl>
References: <20100727004113.GA3714@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 28 Jul 2010 11:36:29 +0400
Message-ID: <1280302589.6376.1.camel@vase.work>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Daniel Kiper <dkiper@net-space.pl>
Cc: jeremy@goop.org, gregkh@suse.de, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

D? D?N?N?, 27/07/2010 D2 02:41 +0200, Daniel Kiper D?D,N?DuN?:
> Hi,
> 
> Currently there is fully working version.
> It has been tested on Xen Ver. 4.0.0 in PV
> guest i386/x86_64 with Linux kernel Ver. 2.6.32.16
> and Ver. 2.6.34.1. This patch cleanly applys
> to Ver. 2.6.34.1 (also as attachment because
> I received some reports that my patches are
> mangled). All found bugs have been removed
> (Sorry however I am sure that some hidden
> still exists :-((().


Work's fine with opensuse 11.3 (dom0 and domU)


-- 
Vasiliy G Tolstov <v.tolstov@selfip.ru>
Selfip.Ru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

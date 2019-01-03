Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED738E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 16:56:25 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id y85so9347124wmc.7
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 13:56:25 -0800 (PST)
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id g14si29939362wrw.285.2019.01.03.13.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 13:56:23 -0800 (PST)
Date: Thu, 3 Jan 2019 16:56:24 -0500
From: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
Message-ID: <20190103215624.d5ofgpoajq7hu3ob@archlinux.localdomain>
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
 <20190103185452.pwsl7xsf4cp4curz@archlinux.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103185452.pwsl7xsf4cp4curz@archlinux.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Alan Stern <stern@rowland.harvard.edu>, linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

Laura,

On Thu, Jan 03, 2019 at 01:54:52PM -0500, Ga�l PORTAY wrote:
>
> I thought it was not working until I decided to give it a retry today...
> and it works!
> 

Sorry, I figured out that my hack is totally wrong. So forget it.

Regards,
Gael

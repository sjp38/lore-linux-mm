Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C90C6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 15:11:26 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id b14so72928358lfg.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 12:11:26 -0800 (PST)
Received: from blaine.gmane.org ([195.159.176.226])
        by mx.google.com with ESMTPS id r79si30100029lfr.51.2016.11.29.12.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 12:11:25 -0800 (PST)
Received: from list by blaine.gmane.org with local (Exim 4.84_2)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1cBokJ-0006gU-7h
	for linux-mm@kvack.org; Tue, 29 Nov 2016 21:11:19 +0100
From: Holger =?iso-8859-1?q?Hoffst=E4tte?= <holger@applied-asynchrony.com>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Date: Tue, 29 Nov 2016 20:11:13 +0000 (UTC)
Message-ID: <pan$5ab20$ae3f956b$4d65cb1e$af0a8d06@applied-asynchrony.com>
References: <20161121215639.GF13371@merlins.org>
	<20161122160629.uzt2u6m75ash4ved@merlins.org>
	<48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
	<CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
	<20161123063410.GB2864@dhcp22.suse.cz>
	<20161128072315.GC14788@dhcp22.suse.cz>
	<20161129155537.f6qgnfmnoljwnx6j@merlins.org>
	<20161129160751.GC9796@dhcp22.suse.cz>
	<20161129163406.treuewaqgt4fy4kh@merlins.org>
	<CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
	<20161129174019.fywddwo5h4pyix7r@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Tue, 29 Nov 2016 09:40:19 -0800, Marc MERLIN wrote:

>> One thing you can try is to just make the global limits much lower. As in
>> 
>>    echo 2 > /proc/sys/vm/dirty_ratio
>>    echo 1 > /proc/sys/vm/dirty_background_ratio
> 
> I will give that a shot, thank you.

Definitely do - your default values are way too high.

Another thing to try would be to activate the 'new' free-space-tree, i.e.
mount once with space_cache=v2. It will vastly reduce writeback stalls
especially with many small files or updates, and has been working reliably
ever since it landed.

-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

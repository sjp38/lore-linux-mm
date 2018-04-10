Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3F266B0011
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:13:54 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id n188so8681985vkc.1
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:13:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k5sor1241321uab.160.2018.04.10.05.13.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 05:13:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180409181400.GO21835@dhcp22.suse.cz>
References: <20180405142749.GL6312@dhcp22.suse.cz> <20180405151359.GB28128@bombadil.infradead.org>
 <20180405153240.GO6312@dhcp22.suse.cz> <20180405161501.GD28128@bombadil.infradead.org>
 <20180405185444.GQ6312@dhcp22.suse.cz> <20180405201557.GA3666@bombadil.infradead.org>
 <20180406060953.GA8286@dhcp22.suse.cz> <20180408042709.GC32632@bombadil.infradead.org>
 <20180409073407.GD21835@dhcp22.suse.cz> <20180409155157.GC11756@bombadil.infradead.org>
 <20180409181400.GO21835@dhcp22.suse.cz>
From: =?UTF-8?B?0JTQvNC40YLRgNC40Lkg0JvQtdC+0L3RgtGM0LXQsg==?= <dm.leontiev7@gmail.com>
Date: Tue, 10 Apr 2018 15:13:53 +0300
Message-ID: <CA+JonM0MewH8MYBJkriPjLVr_xxMfPb0E=eSAQ3in7V45WUAow@mail.gmail.com>
Subject: Re: __GFP_LOW
Content-Type: multipart/alternative; boundary="f403045f3da4bc0fa605697d74cd"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

--f403045f3da4bc0fa605697d74cd
Content-Type: text/plain; charset="UTF-8"

Hello

I'm not an expert in Linux, but something made me think something is broken
in linux in this discussion.

First, I've noticed the network drivers were allocating memory in interrupt
handlers. That sounds strange to me, because as far as I know, this
behaviour is discouraged and may lead to DDOS attack.

Maybe this weird behaviour should be fixed instead of fixing memory
allocator? Networking must not allocate anything, it must drop packets it
cant handle at the moment. Sorry, we totally screwed up, shit happened,
aliens are attacking, blahblahblah, but we won't allocate a byte for you.

--f403045f3da4bc0fa605697d74cd
Content-Type: text/html; charset="UTF-8"

<div dir="ltr"><div><div><div><div><div>Hello<br><br></div>I&#39;m not an expert in Linux, but something made me think something is broken in linux in this discussion.<br><br></div>First,
 I&#39;ve noticed the network drivers were allocating memory in interrupt 
handlers. That sounds strange to me, because as far as I know, this 
behaviour is discouraged and may lead to DDOS attack.<span class="gmail-im"><br><br></span></div>Maybe
 this weird behaviour should be fixed instead of fixing memory 
allocator? Networking must not allocate anything, it must drop packets 
it cant handle at the moment. Sorry, we totally screwed up, shit 
happened, aliens are attacking, blahblahblah, but we won&#39;t allocate a 
byte for you. <div class="gmail-yj6qo"></div><div class="gmail-adL"><br></div></div></div></div>

--f403045f3da4bc0fa605697d74cd--

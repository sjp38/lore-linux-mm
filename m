Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C52766B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 03:53:29 -0400 (EDT)
Received: by fk-out-0910.google.com with SMTP id z22so128163fkz.6
        for <linux-mm@kvack.org>; Thu, 12 Mar 2009 00:53:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090311122611.GA8804@localhost>
References: <e2dc2c680903110341g6c9644b8j87ce3b364807e37f@mail.gmail.com>
	 <20090311114353.GA759@localhost>
	 <e2dc2c680903110451m3cfa35d9s7a9fd942bcee39eb@mail.gmail.com>
	 <20090311121123.GA7656@localhost>
	 <e2dc2c680903110516v2c66d4a4h6a422cffceb12e2@mail.gmail.com>
	 <20090311122611.GA8804@localhost>
Date: Thu, 12 Mar 2009 08:53:27 +0100
Message-ID: <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com>
Subject: Re: Memory usage per memory zone
From: jack marrow <jackmarrow2@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Can you paste /proc/vmstat, /proc/meminfo, /proc/zoneinfo and
> /proc/slabinfo? Thank you.

Sure, but I don't know if it will help.

The oom info was from in the night, the rest is from now. I have no zoneinfo.

http://pastebin.com/m67409bc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7608B6B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 19:05:19 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k17-v6so9916823ita.1
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 16:05:19 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0012.hostedemail.com. [216.40.44.12])
        by mx.google.com with ESMTPS id n31si12129528ioi.146.2018.03.26.16.05.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 16:05:18 -0700 (PDT)
Message-ID: <1522105514.12357.38.camel@perches.com>
Subject: Re: [PATCH] mm: Use octal not symbolic permissions
From: Joe Perches <joe@perches.com>
Date: Mon, 26 Mar 2018 16:05:14 -0700
In-Reply-To: <alpine.DEB.2.20.1803261535460.93873@chino.kir.corp.google.com>
References: 
	<2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
	 <alpine.DEB.2.20.1803261535460.93873@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2018-03-26 at 15:36 -0700, David Rientjes wrote:
> extending some of these lines to be >80 characters also improves 
> the readability imo.

Right.

I have no personal objection to very occasionally using
line lengths < ~100 chars instead of 80.

AFAIK: neither does Linus.

https://lkml.org/lkml/2016/12/15/749

Beyond that, I believe it's too much left-right eyeball
movement for quick and easy reading comprehension.

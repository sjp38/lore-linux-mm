Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA06377
	for <linux-mm@kvack.org>; Mon, 16 Sep 2002 20:17:14 -0700 (PDT)
Message-ID: <3D869EAF.663B6EC3@digeo.com>
Date: Mon, 16 Sep 2002 20:17:03 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: false NUMA OOM
References: <20020917025035.GY2179@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@zip.com.au
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> ...
> +       for (type = classzone - first_classzone; type >= 0; --type)
> +               for_each_pgdat(pgdat) {
> +                       zone = pgdat->node_zones + type;

Well you'd want to start with (and prefer) the local node's zones?

I'm also wondering whether one shouldn't just poke a remote kswapd
and wait.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

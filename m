Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id VAA07428
	for <linux-mm@kvack.org>; Mon, 16 Sep 2002 21:58:54 -0700 (PDT)
Message-ID: <3D86B683.8101C1D1@digeo.com>
Date: Mon, 16 Sep 2002 21:58:43 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: dbench on tmpfs OOM's
References: <20020917044317.GZ2179@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org, akpm@zip.com.au, hugh@veritas.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> ...
> MemTotal:     32107256 kB
> MemFree:      27564648 kB

I'd be suspecting that your node fallback is bust.

Suggest you add a call to show_free_areas() somewhere; consider
exposing the full per-zone status via /proc with a proper patch.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

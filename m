Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA07800
	for <linux-mm@kvack.org>; Mon, 16 Sep 2002 22:14:03 -0700 (PDT)
Message-ID: <3D86BA1B.84873680@digeo.com>
Date: Mon, 16 Sep 2002 22:14:03 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: dbench on tmpfs OOM's
References: <3D86B683.8101C1D1@digeo.com> <210772234.1032213704@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, akpm@zip.com.au, hugh@veritas.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> >> ...
> >> MemTotal:     32107256 kB
> >> MemFree:      27564648 kB
> >
> > I'd be suspecting that your node fallback is bust.
> >
> > Suggest you add a call to show_free_areas() somewhere; consider
> > exposing the full per-zone status via /proc with a proper patch.
> 
> Won't /proc/meminfo.numa show that? Or do you mean something
> else by "full per-zone status"?

meminfo.what?   Remember when I suggested that you put
a testing mode into the numa code so that mortals could
run numa builds on non-numa boxes?


> Looks to me like it's just out of low memory:
> 
> > LowFree:          1424 kB
> 
> There is no low memory on anything but node 0 ...
> 

It was a GFP_HIGH allocation - just pagecache.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

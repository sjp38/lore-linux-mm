Date: Mon, 16 Sep 2002 22:01:46 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: dbench on tmpfs OOM's
Message-ID: <210772234.1032213704@[10.10.2.3]>
In-Reply-To: <3D86B683.8101C1D1@digeo.com>
References: <3D86B683.8101C1D1@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org, akpm@zip.com.au, hugh@veritas.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> ...
>> MemTotal:     32107256 kB
>> MemFree:      27564648 kB
> 
> I'd be suspecting that your node fallback is bust.
> 
> Suggest you add a call to show_free_areas() somewhere; consider
> exposing the full per-zone status via /proc with a proper patch.

Won't /proc/meminfo.numa show that? Or do you mean something
else by "full per-zone status"?

Looks to me like it's just out of low memory:

> LowFree:          1424 kB

There is no low memory on anything but node 0 ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

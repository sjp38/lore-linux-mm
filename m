Date: Mon, 16 Sep 2002 22:15:01 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: dbench on tmpfs OOM's
Message-ID: <20020917051501.GM3530@holomorphy.com>
References: <20020917044317.GZ2179@holomorphy.com> <3D86B683.8101C1D1@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D86B683.8101C1D1@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, akpm@zip.com.au, hugh@veritas.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> MemTotal:     32107256 kB
>> MemFree:      27564648 kB

On Mon, Sep 16, 2002 at 09:58:43PM -0700, Andrew Morton wrote:
> I'd be suspecting that your node fallback is bust.
> Suggest you add a call to show_free_areas() somewhere; consider
> exposing the full per-zone status via /proc with a proper patch.

I went through the nodes by hand. It's just a run of the mill
ZONE_NORMAL OOM coming out of the GFP_USER allocation. None of
the highmem zones were anywhere near ->pages_low.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

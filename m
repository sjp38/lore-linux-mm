Date: Mon, 14 Oct 2002 18:29:49 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [Lse-tech] Re: [rfc][patch] Memory Binding API v0.3 2.5.41
Message-ID: <2008756258.1034620187@[10.10.2.3]>
In-Reply-To: <20021015012015.GN4488@holomorphy.com>
References: <20021015012015.GN4488@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: john stultz <johnstul@us.ibm.com>, Matt <colpatch@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE Tech <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

>> No, the NUMA code in the kernel doesn't support that anyway.
>> You have to use zholes_size, and waste some struct pages,
>> or config_nonlinear. Either way you get 1 memblk.
> 
> I thought zholes stuff freed the struct pages. Maybe that was done
> by hand.

The only place I see that used in generic code is
calculate_zone_totalpages, free_area_init_core, free_area_init_node,
none of which seem to do that. But cscope might be borked again, I
guess. Must be done in each arch if at all ... which arch did you
think did it?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

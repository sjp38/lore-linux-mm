Date: Wed, 23 Oct 2002 18:43:17 +0530
From: Ravikiran G Thirumalai <kiran@in.ibm.com>
Subject: Re: 2.5.44-mm3
Message-ID: <20021023184317.A32662@in.ibm.com>
References: <3DB6067E.C95174FC@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DB6067E.C95174FC@digeo.com>; from akpm@digeo.com on Wed, Oct 23, 2002 at 02:17:59AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rusty@rustcorp.com.au
List-ID: <linux-mm.kvack.org>

Hi,
My machine did not boot with CONFIG_NR_CPUS = 4.  Same .config as one
used for 2.5.44-mm2.  Could be the __node_to_cpu_mask redifinition from
the larger-cpu-masks patch .... 

Thanks,
Kiran
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

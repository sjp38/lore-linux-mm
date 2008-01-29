Date: Tue, 29 Jan 2008 09:39:48 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [patch 2/6] mm: bdi: export BDI attributes in sysfs
Message-ID: <20080129173948.GA14450@kroah.com>
References: <20080129154900.145303789@szeredi.hu> <20080129154948.823761079@szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080129154948.823761079@szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Kay Sievers <kay.sievers@vrfy.org>, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2008 at 04:49:02PM +0100, Miklos Szeredi wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> Provide a place in sysfs (/sys/class/bdi) for the backing_dev_info
> object.  This allows us to see and set the various BDI specific
> variables.
> 
> In particular this properly exposes the read-ahead window for all
> relevant users and /sys/block/<block>/queue/read_ahead_kb should be
> deprecated.
> 
> With patient help from Kay Sievers and Greg KH
> 
> [mszeredi@suse.cz]
> 
>  - split off NFS and FUSE changes into separate patches
>  - document new sysfs attributes under Documentation/ABI
>  - do bdi_class_init as a core_initcall, otherwise the "default" BDI
>    won't be initialized
>  - remove bdi_init_fmt macro, it's not used very much
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Kay Sievers <kay.sievers@vrfy.org>
> CC: Greg KH <greg@kroah.com>

Acked-by: Greg Kroah-Hartman <gregkh@suse.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

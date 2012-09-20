Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 60F336B0044
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 04:45:15 -0400 (EDT)
Date: Thu, 20 Sep 2012 16:45:07 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH v3 2/2] Documentation: add description of
 dirty_background_centisecs
Message-ID: <20120920084507.GB5697@localhost>
References: <1347798364-2864-1-git-send-email-linkinjeon@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347798364-2864-1-git-send-email-linkinjeon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

[ add CC ]

On Sun, Sep 16, 2012 at 08:26:04AM -0400, Namjae Jeon wrote:
> From: Namjae Jeon <namjae.jeon@samsung.com>
> 
> This commit adds dirty_background_centisecs description in bdi sysfs
> documentation.
> 
> Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
> ---
>  Documentation/ABI/testing/sysfs-class-bdi |   25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
> 
> diff --git a/Documentation/ABI/testing/sysfs-class-bdi b/Documentation/ABI/testing/sysfs-class-bdi
> index 5f50097..6869736 100644
> --- a/Documentation/ABI/testing/sysfs-class-bdi
> +++ b/Documentation/ABI/testing/sysfs-class-bdi
> @@ -48,3 +48,28 @@ max_ratio (read-write)
>  	most of the write-back cache.  For example in case of an NFS
>  	mount that is prone to get stuck, or a FUSE mount which cannot
>  	be trusted to play fair.
> +
> +dirty_background_centisecs (read-write)
> +
> +	It is used to start early writeback of given bdi once bdi dirty
> +	data exceeds product of average write bandwidth and
> +	dirty_background_centisecs. It works in parallel of
> +	dirty_writeback_centsecs and dirty_expire_interval based periodic
> +	flushing mechanism.
> +
> +        It is mainly useful for tuning writeback speed at 'NFS Server'
> +	sothat NFS client could see better write speed.
> +	A good use case is setting it to around 100 (1 second) in the NFS
> +	server for improving NFS write performance. Note that it's not
> +	recommended to set it to a too small value, which might lead to
> +	unnecessary flushing for small IO size.
> +        Setting it to 0 disables the feature.
> +
> +	However, sometimes it may not match user expectations as it is based
> +	on bdi write bandwidth estimation. The users should not expect this
> +	threshold to work accurately.
> +	Write bandwidth estimation is a best effort to estimate bdi write
> +	speed bandwidth. But it can be wildly wrong in certain situations
> +	such as sudden change of workload (including the workload startup
> +	stage), or if there are no heavy writes since boot, in which case
> +	there is no reasonable estimation yet.
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3E6B46B00D0
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 23:03:04 -0400 (EDT)
Date: Mon, 13 Sep 2010 11:02:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] writeback: Adding
 /sys/devices/system/node/<node>/vmstat
Message-ID: <20100913030256.GC7697@localhost>
References: <1284323440-23205-1-git-send-email-mrubin@google.com>
 <1284323440-23205-5-git-send-email-mrubin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284323440-23205-5-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 04:30:39AM +0800, Michael Rubin wrote:
> For NUMA node systems it is important to have visibility in memory
> characteristics. Two of the /proc/vmstat values "nr_cleaned" and

s/nr_cleaned/nr_written/

> "nr_dirtied" are added here.
> 
> 	# cat /sys/devices/system/node/node20/vmstat
> 	nr_cleaned 0

ditto

> 	nr_dirtied 0
> 
> Signed-off-by: Michael Rubin <mrubin@google.com>

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

> +static ssize_t node_read_vmstat(struct sys_device *dev,
> +				struct sysdev_attribute *attr, char *buf)
> +{
> +	int nid = dev->id;
> +	return sprintf(buf,
> +		"nr_written %lu\n"
> +		"nr_dirtied %lu\n",
> +		node_page_state(nid, NR_WRITTEN),
> +		node_page_state(nid, NR_FILE_DIRTIED));
> +}

Do you have plan to port more vmstat_text[] items? :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

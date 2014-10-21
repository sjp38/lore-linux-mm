Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5656B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 23:38:52 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kx10so439634pab.23
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 20:38:52 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id oe4si9560119pdb.197.2014.10.20.20.38.50
        for <linux-mm@kvack.org>;
        Mon, 20 Oct 2014 20:38:51 -0700 (PDT)
Date: Tue, 21 Oct 2014 14:38:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: UBIFS assert failed in ubifs_set_page_dirty at 1421
Message-ID: <20141021033847.GS17506@dastard>
References: <BE257DAADD2C0D439647A271332966573949EFEC@SZXEMA511-MBS.china.huawei.com>
 <1413805935.7906.225.camel@sauron.fi.intel.com>
 <C3050A4DBA34F345975765E43127F10F62CC5D9B@SZXEMA512-MBX.china.huawei.com>
 <1413810719.7906.268.camel@sauron.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413810719.7906.268.camel@sauron.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Artem Bityutskiy <dedekind1@gmail.com>
Cc: Caizhiyong <caizhiyong@hisilicon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Jijiagang <jijiagang@hisilicon.com>, "adrian.hunter@intel.com" <adrian.hunter@intel.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "Wanli (welly)" <welly.wan@hisilicon.com>

On Mon, Oct 20, 2014 at 04:11:59PM +0300, Artem Bityutskiy wrote:
> 3. There are exactly 2 places where UBIFS-backed pages may be marked as
> dirty:
> 
>   a) ubifs_write_end() [->wirte_end] - the file write path
>   b) ubifs_page_mkwrite() [->page_mkwirte] - the file mmap() path
> 
> 4. If anything calls 'ubifs_set_page_dirty()' directly (not through
> write_end()/mkwrite()), and the page was not dirty, UBIFS will complain
> with the assertion that you see.
> 
> > CPU: 3 PID: 543 Comm: kswapd0 Tainted: P           O 3.10.0_s40 #1

Kernel is tainted. Not worth wasting time on unless it can be
reproduced on an untainted kernel...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

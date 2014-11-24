Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0414880110
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:28:13 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so5742276wiv.14
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 05:28:12 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id ge2si12073219wib.95.2014.11.24.05.28.11
        for <linux-mm@kvack.org>;
        Mon, 24 Nov 2014 05:28:11 -0800 (PST)
Date: Mon, 24 Nov 2014 15:27:55 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: UBIFS assert failed in ubifs_set_page_dirty at 1421
Message-ID: <20141124132755.GA3167@node.dhcp.inet.fi>
References: <BE257DAADD2C0D439647A271332966573949EFEC@SZXEMA511-MBS.china.huawei.com>
 <1413805935.7906.225.camel@sauron.fi.intel.com>
 <C3050A4DBA34F345975765E43127F10F62CC5D9B@SZXEMA512-MBX.china.huawei.com>
 <1413810719.7906.268.camel@sauron.fi.intel.com>
 <545C2CEE.5020905@huawei.com>
 <20141120123011.GA9716@node.dhcp.inet.fi>
 <BE257DAADD2C0D439647A27133296657394A65A4@SZXEMA511-MBS.china.huawei.com>
 <20141124091024.GA1190@node.dhcp.inet.fi>
 <BE257DAADD2C0D439647A27133296657394A75F1@SZXEMA511-MBS.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BE257DAADD2C0D439647A27133296657394A75F1@SZXEMA511-MBS.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jijiagang <jijiagang@hisilicon.com>
Cc: Hujianyang <hujianyang@huawei.com>, "dedekind1@gmail.com" <dedekind1@gmail.com>, Caizhiyong <caizhiyong@hisilicon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wanli (welly)" <welly.wan@hisilicon.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "adrian.hunter@intel.com" <adrian.hunter@intel.com>

On Mon, Nov 24, 2014 at 10:20:59AM +0000, Jijiagang wrote:
> Hi Kirill,
> I test your patch, bus there's no dump_vma definition.
> The log is here, hope it will be helpful.
> 
>  page:817fd7e0 count:3 mapcount:1 mapping:a318bb8c index:0x4
>  page flags: 0xa19(locked|uptodate|dirty|arch_1|private)
>  pte_write: 1
>  page:81441a80 count:3 mapcount:1 mapping:a318bb8c index:0x5
>  page flags: 0x209(locked|uptodate|arch_1)
>  pte_write: 1

Okay, pte is writable but page is not dirty and doesn't have private flag
set.

I looked through code and don't see how that could happen.

>  UBIFS assert failed in ubifs_set_page_dirty at 1422 (pid 545)
>  CPU: 2 PID: 545 Comm: kswapd0 Tainted: P           O 3.10.0_s40 #19

Is it possible to reproduce the issue on current upstream without any
patches or third-party modules?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

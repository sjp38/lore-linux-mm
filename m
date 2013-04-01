Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 480266B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 13:56:20 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa10so1423633pad.41
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 10:56:19 -0700 (PDT)
Date: Mon, 1 Apr 2013 10:56:16 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: zcache: fix compile error
Message-ID: <20130401175616.GA18333@kroah.com>
References: <1364788247-30657-1-git-send-email-bob.liu@oracle.com>
 <20130401121736.GA11995@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130401121736.GA11995@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Bob Liu <lliubbo@gmail.com>, dan.magenheimer@oracle.com, fengguang.wu@intel.com, linux-mm@kvack.org, Bob Liu <bob.liu@oracle.com>

On Mon, Apr 01, 2013 at 08:17:36AM -0400, Konrad Rzeszutek Wilk wrote:
> On Mon, Apr 01, 2013 at 11:50:47AM +0800, Bob Liu wrote:
> > --- a/drivers/staging/zcache/zcache-main.c
> > +++ b/drivers/staging/zcache/zcache-main.c
> > @@ -1753,9 +1753,7 @@ static int zcache_init(void)
> >  		namestr = "ramster";
> >  		ramster_register_pamops(&zcache_pamops);
> >  	}
> > -#ifdef CONFIG_DEBUG_FS
> >  	zcache_debugfs_init();
> > -#endif
> >  	if (zcache_enabled) {
> >  		unsigned int cpu;
> >  
> 
> That looks OK, and should be as a seperate patch - as there are no compilation
> failures with zcache-main.c

No, make it in the same patch, it is relevant here.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

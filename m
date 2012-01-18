Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 4697D6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 10:02:06 -0500 (EST)
Date: Wed, 18 Jan 2012 07:00:07 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH v2 1/2] Making si_swapinfo exportable
Message-ID: <20120118150007.GA18315@suse.de>
References: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
 <56cc3c5d40a8653b7d9bef856ff02d909b98f36f.1326803859.git.leonid.moiseichuk@nokia.com>
 <CAOJsxLHfHHrFyhfkSe8mbsnJHBkgKtksCZZDwN6K3d7KJqfzkQ@mail.gmail.com>
 <20120118140904.GB13817@suse.de>
 <20120118144618.GA7438@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120118144618.GA7438@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Wed, Jan 18, 2012 at 09:46:18AM -0500, Konrad Rzeszutek Wilk wrote:
> > > > +EXPORT_SYMBOL(si_swapinfo);
> > 
> > EXPORT_SYMBOL_GPL() perhaps?
> 
> Greg,
> 
> So.. could you tell when are suppose to do _GPL and when not? Is there
> a policy of "new code must be _GPL" ? Or is there some extra "if .. then"
> conditions?

It's up to the author of the code, what their preference is.

I just generally prefer _GPL for new exports.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

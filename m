Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 0F17F6B0032
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 20:44:06 -0500 (EST)
Date: Wed, 6 Feb 2013 10:44:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: Add Kconfig for enabling PTE method
Message-ID: <20130206014404.GG11197@blaptop>
References: <1359937421-19921-1-git-send-email-minchan@kernel.org>
 <20130204185146.GA31284@kroah.com>
 <20130205000854.GC2610@blaptop>
 <20130205192520.GA8441@kroah.com>
 <20130206011721.GE11197@blaptop>
 <20130206014259.GC816@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130206014259.GC816@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Greg,

On Tue, Feb 05, 2013 at 05:42:59PM -0800, Greg Kroah-Hartman wrote:
> On Wed, Feb 06, 2013 at 10:17:21AM +0900, Minchan Kim wrote:
> > > > > Did you test this?  I don't see the new config value you added actually
> > > > > do anything in this code.  Also, if I select it incorrectly on ARM, or
> > > > 
> > > > *slaps self*
> > > 
> > > Ok, so I'll drop this patch now.  As for what to do instead, I have no
> > > idea, sorry, but the others should.
> > 
> > Okay. Then, let's discuss further.
> > The history we introuced copy-based method is due to portability casused by
> > set_pte and __flush_tlb_one usage in young zsmalloc age. They are gone now
> > so there isn't issue any more. But we found copy-based method is 3 times faster
> > than pte-based in VM so I expect you guys don't want to give up it for just
> > portability. Of course,
> > I can't give up pte-based model as you know well, it's 6 times faster than
> > copy-based model in ARM.
> > 
> > Hard-coding for some arch like now isn't good and Kconfig for selecting choice
> > was rejected by Greg as you can see above.
> 
> I rejected your patch because it did not do anything, why would I accept
> it?
> 
> What would you have done in my situation?
> 
> It's not an issue of "portability" or "speed" or anything other than
> "the patch you sent was obviously not correct."

I totally misunderstood that you'd like to solve this issue.
"Also, if I select it incorrectly on ARM, or
or other platforms, what is keeping this from doing bad things?"
Then, I will resend it soon.

Thanks.

> 
> greg k-h
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

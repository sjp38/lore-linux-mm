Subject: Re: [PATCH] aic7xxx parallel build
From: John Cherry <cherry@osdl.org>
In-Reply-To: <1251588112.1074819190@aslan.btc.adaptec.com>
References: <1074800332.29125.55.camel@cherrypit.pdx.osdl.net>
	 <1251588112.1074819190@aslan.btc.adaptec.com>
Content-Type: text/plain
Message-Id: <1074819272.15610.2.camel@cherrypit.pdx.osdl.net>
Mime-Version: 1.0
Date: Thu, 22 Jan 2004 16:54:32 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Justin T. Gibbs" <gibbs@scsiguy.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Yeah.  It looks like I grabbed my old patch from the last successful
parallel build that Andrew ran.

I'll run the regressions on the Makefiles you have supplied tonight.  I
have no doubts that this will be successful.  Thanks.

John

On Thu, 2004-01-22 at 16:53, Justin T. Gibbs wrote:
> > The Makefiles for aic7xxx and aicasm have changed since I submitted a
> > patch for the parallel build problem several months ago.  Justin's patch
> > has disappeared from the mm builds, so we continue to have parallel
> > build problems.
> > 
> > The following patch fixes the parallel build problem and it still
> > applies to 2.6.2-rc1-mm1.  This is Justin's fix.
> 
> Actually, that's not my fix.  This looks like your original fix.
> I've attached aic7xxx/Makefile and aic7xxx/aicasm/Makefile from my
> tree.  These seem to work just fine in my parallel build tests and
> will work regardless of which generated file is out of date - a flaw
> in your change.  Please let me know if these files don't work for you.
> 
> --
> Justin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Subject: Re: 2.5.65-mm2
From: "Steven P. Cole" <elenstev@mesatop.com>
Reply-To: elenstev@mesatop.com
In-Reply-To: <20030319163337.602160d8.akpm@digeo.com>
References: <20030319012115.466970fd.akpm@digeo.com>
	 <1048103489.1962.87.camel@spc9.esa.lanl.gov>
	 <20030319121055.685b9b8c.akpm@digeo.com>
	 <1048107434.1743.12.camel@spc1.esa.lanl.gov>
	 <1048111359.1807.13.camel@spc1.esa.lanl.gov>
	 <20030319163337.602160d8.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1048117516.1602.6.camel@spc1.esa.lanl.gov>
Mime-Version: 1.0
Date: 19 Mar 2003 16:45:16 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-03-19 at 17:33, Andrew Morton wrote:
> "Steven P. Cole" <elenstev@mesatop.com> wrote:
> >
> > > 
> > > Summary: using ext3, the simple window shake and scrollbar wiggle tests
> > > were much improved, but really using Evolution left much to be desired.
> > 
> > Replying to myself for a followup,
> > 
> > I repeated the tests with 2.5.65-mm2 elevator=deadline and the situation
> > was similar to elevator=as.  Running dbench on ext3, the response to
> > desktop switches and window wiggles was improved over running dbench on
> > reiserfs, but typing in Evolution was subject to long delays with dbench
> > clients greater than 16.
> 
> OK, final question before I get off my butt and find a way to reproduce this:
> 
> Does reverting
> 
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.65/2.5.65-mm2/broken-out/sched-2.5.64-D3.patch
> 
> help?

Sorry, didn't have much time for a lot of testing, but no miracles
occurred.  With 5 minutes of testing 2.5.65-mm2 and dbench 24 on ext3
and that patch reverted (first hunk had to be manually fixed), I don't
see any improvement.  Still the same long long delays in trying to use
Evolution. 

Steven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

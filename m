Subject: Re: 2.5.68-mm4
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <1051912190.14310.2.camel@andyp.pdx.osdl.net>
References: <20030502020149.1ec3e54f.akpm@digeo.com>
	 <1051905879.2166.34.camel@spc9.esa.lanl.gov>
	 <20030502133405.57207c48.akpm@digeo.com>
	 <1051908541.2166.40.camel@spc9.esa.lanl.gov>
	 <20030502140508.02d13449.akpm@digeo.com>
	 <1051910420.2166.55.camel@spc9.esa.lanl.gov>
	 <1051912190.14310.2.camel@andyp.pdx.osdl.net>
Content-Type: text/plain
Message-Id: <1051912828.2163.60.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 02 May 2003 16:00:29 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Pfiffer <andyp@osdl.org>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-05-02 at 15:49, Andy Pfiffer wrote:
> > > > > I found that e100 failed to bring up the
> > > > > interface on restart ("failed selftest"), but eepro100 was OK.
> 
> > Here is a snippet from dmesg output for a successful kexec e100 boot:
> 
> Any chance we could get lspci output from both of these systems?

Sure.  I posted that initially.  See this:

http://marc.theaimsgroup.com/?l=linux-kernel&m=105190618322919&w=2

Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

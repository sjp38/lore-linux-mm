Subject: Re: 2.5.68-mm4
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <20030502140508.02d13449.akpm@digeo.com>
References: <20030502020149.1ec3e54f.akpm@digeo.com>
	 <1051905879.2166.34.camel@spc9.esa.lanl.gov>
	 <20030502133405.57207c48.akpm@digeo.com>
	 <1051908541.2166.40.camel@spc9.esa.lanl.gov>
	 <20030502140508.02d13449.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1051910420.2166.55.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 02 May 2003 15:20:20 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-05-02 at 15:05, Andrew Morton wrote:
> Steven Cole <elenstev@mesatop.com> wrote:
> >
> > On Fri, 2003-05-02 at 14:34, Andrew Morton wrote:
> > > Steven Cole <elenstev@mesatop.com> wrote:
> > > >
> > > > For what it's worth, kexec has worked for me on the following
> > > > two systems.
> > > > ...
> > > > 00:03.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 08)
> > > 
> > > Are you using eepro100 or e100?  I found that e100 failed to bring up the
> > > interface on restart ("failed selftest"), but eepro100 was OK.
> > 
> > CONFIG_EEPRO100=y
> > # CONFIG_EEPRO100_PIO is not set
> > # CONFIG_E100 is not set
> > 
> > I can test E100 again to verify if that would help.
> 
> May as well.
> 
> There's something in the driver shutdown which is failing to bring the
> device into a state in which the driver startup can start it up.  Probably
> just a missing device reset.  I'll bug Scott about it if we get that far.
> 
Here is a snippet from dmesg output for a successful kexec e100 boot:

Intel(R) PRO/100 Network Driver - version 2.2.21-k1
Copyright (c) 2003 Intel Corporation

e100: selftest OK.
Freeing alive device c1b23000, eth%d
e100: eth0: Intel(R) PRO/100 Network Connection
  Hardware receive checksums enabled
  cpu cycle saver enabled

I booted the e100 2.5.68-mm4 kernel twice with kexec, initially from the
eepro100 version, and once from the e100 version.  Both worked OK.

Steven
  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

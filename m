Subject: Re: 2.5.68-mm4
From: Andy Pfiffer <andyp@osdl.org>
In-Reply-To: <1051910420.2166.55.camel@spc9.esa.lanl.gov>
References: <20030502020149.1ec3e54f.akpm@digeo.com>
	 <1051905879.2166.34.camel@spc9.esa.lanl.gov>
	 <20030502133405.57207c48.akpm@digeo.com>
	 <1051908541.2166.40.camel@spc9.esa.lanl.gov>
	 <20030502140508.02d13449.akpm@digeo.com>
	 <1051910420.2166.55.camel@spc9.esa.lanl.gov>
Content-Type: text/plain
Message-Id: <1051912190.14310.2.camel@andyp.pdx.osdl.net>
Mime-Version: 1.0
Date: 02 May 2003 14:49:50 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > I found that e100 failed to bring up the
> > > > interface on restart ("failed selftest"), but eepro100 was OK.

> Here is a snippet from dmesg output for a successful kexec e100 boot:

Any chance we could get lspci output from both of these systems?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

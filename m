Subject: Re: 2.5.68-mm4
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <20030502133405.57207c48.akpm@digeo.com>
References: <20030502020149.1ec3e54f.akpm@digeo.com>
	 <1051905879.2166.34.camel@spc9.esa.lanl.gov>
	 <20030502133405.57207c48.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1051908541.2166.40.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 02 May 2003 14:49:02 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-05-02 at 14:34, Andrew Morton wrote:
> Steven Cole <elenstev@mesatop.com> wrote:
> >
> > For what it's worth, kexec has worked for me on the following
> > two systems.
> > ...
> > 00:03.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 08)
> 
> Are you using eepro100 or e100?  I found that e100 failed to bring up the
> interface on restart ("failed selftest"), but eepro100 was OK.

CONFIG_EEPRO100=y
# CONFIG_EEPRO100_PIO is not set
# CONFIG_E100 is not set

I can test E100 again to verify if that would help.

Also, I found that if I mistyped the argument to do-kexec.sh, the
system would stay up, but the interface would get hosed, fixable with
/etc/rc.d/init.d/network restart.

Otherwise, kexec works fine here so far over about a dozen reboots on
both machines.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

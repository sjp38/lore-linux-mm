Date: Tue, 8 Jul 2003 04:26:44 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm2 + nvidia (and others)
Message-ID: <20030708112644.GH15452@holomorphy.com>
References: <1057590519.12447.6.camel@sm-wks1.lan.irkk.nu> <1057647818.5489.385.camel@workshop.saharacpt.lan> <20030708072604.GF15452@holomorphy.com> <200307081051.41683.schlicht@uni-mannheim.de> <20030708085558.GG15452@holomorphy.com> <1057657046.1819.11.camel@mufasa.ds.co.ug> <20030708110122.GA10756@vana.vc.cvut.cz> <1057663430.2449.5.camel@laurelin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1057663430.2449.5.camel@laurelin>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Flameeyes <dgp85@users.sourceforge.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2003-07-08 at 13:01, Petr Vandrovec wrote:
>> vmware-any-any-update35.tar.gz should work on 2.5.74-mm2 too.
>> But it is not tested, I have enough troubles with 2.5.74 without mm patches...

On Tue, Jul 08, 2003 at 01:23:50PM +0200, Flameeyes wrote:
> vmnet doesn't compile:
> make: Entering directory `/tmp/vmware-config1/vmnet-only'
> In file included from userif.c:51:
> pgtbl.h: In function `PgtblVa2PageLocked':
> pgtbl.h:82: warning: implicit declaration of function `pmd_offset'
> pgtbl.h:82: warning: assignment makes pointer from integer without a
> cast
> make: Leaving directory `/tmp/vmware-config1/vmnet-only'

I've got some long-running benchmarks going at the moment on my main
dev boxen but I should be able to get a fix going soon.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 016CF8D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 07:20:11 -0500 (EST)
Date: Fri, 12 Nov 2010 13:20:03 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: BUG: Bad page state in process (current git)
Message-ID: <20101112122003.GA1572@arch.trippelsdorf.de>
References: <20101110152519.GA1626@arch.trippelsdorf.de>
 <20101110154057.GA2191@arch.trippelsdorf.de>
 <alpine.DEB.2.00.1011101534370.30164@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011101534370.30164@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 2010.11.10 at 15:46 -0600, Christoph Lameter wrote:
> On Wed, 10 Nov 2010, Markus Trippelsdorf wrote:
> 
> > I found this in my dmesg:
> > ACPI: Local APIC address 0xfee00000
> >  [ffffea0000000000-ffffea0003ffffff] PMD -> [ffff8800d0000000-ffff8800d39fffff] on node 0
> 
> That only shows you how the memmap was virtually mapped.

Yes. Fortunately the BUG is gone since I pulled the upcoming drm fixes
from: 
git://git.kernel.org/pub/scm/linux/kernel/git/airlied/drm-2.6.git drm-fixes

Maybe 06fba6d4168069d8 fixed it.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

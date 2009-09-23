Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2D3D06B0055
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 17:44:23 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [BUG 2.6.30+] e100 sometimes causes oops during resume
Date: Wed, 23 Sep 2009 23:45:12 +0200
References: <20090915120538.GA26806@bizet.domek.prywatny> <200909230151.36678.rjw@sisk.pl> <20090923142225.GA2603@bizet.domek.prywatny>
In-Reply-To: <20090923142225.GA2603@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200909232345.12186.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: david.graham@intel.com, "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 23 September 2009, Karol Lewandowski wrote:
> On Wed, Sep 23, 2009 at 01:51:36AM +0200, Rafael J. Wysocki wrote:
> > On Wednesday 23 September 2009, Karol Lewandowski wrote:
> > > On Fri, Sep 18, 2009 at 12:27:37AM +0200, Rafael J. Wysocki wrote:
> > > > Adding linux-mm to the CC list.
> > > 
> > > I've hit this bug 2 times since my last email.  Is there anything I
> > > could do?
> > > 
> > > Maybe I should revert following commits (chosen somewhat randomly)?
> > > 
> > > 1. 49255c619fbd482d704289b5eb2795f8e3b7ff2e
> > > 
> > > 2. dd5d241ea955006122d76af88af87de73fec25b4 - alters changes made by
> > > commit above
> > > 
> > > Any ideas?
> > 
> > You can try that IMO.
> 
> Reverting commits above made situation worse.  Hints?  Obvious
> solutions? ;-)

Not really, at least not from me. :-(

Best,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
